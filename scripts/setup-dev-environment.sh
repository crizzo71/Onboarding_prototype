#!/bin/bash

# HyperFleet Development Environment Setup Script
# This script automates the setup of a local development environment for HyperFleet
#
# Usage: ./scripts/setup-dev-environment.sh
#
# Requirements:
# - macOS or Linux
# - Docker installed and running
# - Internet connection
# - Git configured with user email

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KIND_CLUSTER_NAME="hyperfleet-dev"
POSTGRES_PASSWORD="development-password"
RABBITMQ_PASSWORD="development"

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        return 1
    fi
    return 0
}

check_docker_running() {
    if ! docker ps &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        return 1
    fi
    return 0
}

# Main setup functions
check_prerequisites() {
    print_status "Checking prerequisites..."

    local missing_deps=()

    # Check required commands
    for cmd in docker kubectl kind helm go git jq; do
        if ! check_command "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo
        echo "Install instructions:"
        echo "macOS: brew install ${missing_deps[*]}"
        echo "Linux: See https://kubernetes.io/docs/tasks/tools/ for kubectl, kind, helm"
        exit 1
    fi

    check_docker_running

    # Check Git configuration
    if ! git config user.email &> /dev/null; then
        print_error "Git user.email not configured. Please run:"
        echo "  git config --global user.email 'your.email@redhat.com'"
        exit 1
    fi

    print_success "All prerequisites satisfied"
}

create_kind_cluster() {
    print_status "Setting up Kind cluster: $KIND_CLUSTER_NAME"

    # Check if cluster already exists
    if kind get clusters | grep -q "$KIND_CLUSTER_NAME"; then
        print_warning "Cluster $KIND_CLUSTER_NAME already exists. Deleting..."
        kind delete cluster --name "$KIND_CLUSTER_NAME"
    fi

    # Create Kind cluster configuration
    cat > /tmp/kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $KIND_CLUSTER_NAME
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
- role: worker
- role: worker
EOF

    # Create the cluster
    kind create cluster --config=/tmp/kind-config.yaml

    # Wait for cluster to be ready
    print_status "Waiting for cluster to be ready..."
    kubectl wait --for=condition=ready nodes --all --timeout=300s

    print_success "Kind cluster created successfully"
}

install_operators() {
    print_status "Installing required operators..."

    # Install cert-manager
    print_status "Installing cert-manager..."
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.13.0/cert-manager.yaml
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager

    # Install Prometheus Operator
    print_status "Installing Prometheus Operator..."
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus-operator -n default

    print_success "Operators installed successfully"
}

setup_database() {
    print_status "Setting up PostgreSQL database..."

    # Deploy PostgreSQL
    kubectl apply -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-dev
  namespace: default
  labels:
    app: postgres-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-dev
  template:
    metadata:
      labels:
        app: postgres-dev
    spec:
      containers:
      - name: postgres
        image: postgres:14
        env:
        - name: POSTGRES_DB
          value: hyperfleet_dev
        - name: POSTGRES_USER
          value: hyperfleet
        - name: POSTGRES_PASSWORD
          value: "$POSTGRES_PASSWORD"
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-dev
  namespace: default
spec:
  selector:
    app: postgres-dev
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF

    # Wait for PostgreSQL to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/postgres-dev
    print_success "PostgreSQL database setup complete"
}

setup_message_broker() {
    print_status "Setting up RabbitMQ message broker..."

    # Add Bitnami Helm repository
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

    # Install RabbitMQ
    helm install rabbitmq-dev bitnami/rabbitmq \
        --set auth.username=hyperfleet \
        --set auth.password="$RABBITMQ_PASSWORD" \
        --set persistence.enabled=false \
        --set service.type=ClusterIP \
        --wait

    print_success "RabbitMQ message broker setup complete"
}

clone_repositories() {
    print_status "Setting up HyperFleet workspace..."

    local workspace_dir="$HOME/workspace/hyperfleet"
    mkdir -p "$workspace_dir"
    cd "$workspace_dir"

    # List of HyperFleet repositories
    local repos=(
        "hyperfleet-api"
        "hyperfleet-sentinel"
        "hyperfleet-adapter"
        "hyperfleet-broker"
        "architecture"
    )

    for repo in "${repos[@]}"; do
        if [ -d "$repo" ]; then
            print_warning "Repository $repo already exists, skipping clone"
        else
            print_status "Cloning $repo..."
            # Note: In real implementation, these would be actual repo URLs
            git clone "https://github.com/openshift-hyperfleet/$repo.git" || {
                print_warning "Could not clone $repo (may not exist yet)"
            }
        fi
    done

    print_success "Workspace setup complete at $workspace_dir"
}

setup_container_registry_access() {
    print_status "Setting up container registry access..."

    # Test Docker Hub access (public images)
    docker pull postgres:14 > /dev/null 2>&1 || {
        print_error "Cannot pull from Docker Hub. Check your Docker configuration."
        return 1
    }

    # Note: Quay.io access would require authentication
    print_warning "Quay.io access requires Red Hat credentials. Please run:"
    echo "  docker login quay.io"
    echo "  # Enter your Red Hat credentials"

    print_success "Container registry access configured"
}

create_env_file() {
    print_status "Creating environment configuration..."

    cat > ~/.hyperfleet-dev.env << EOF
# HyperFleet Development Environment Configuration
# Source this file: source ~/.hyperfleet-dev.env

export KUBECONFIG="$HOME/.kube/config"
export KIND_CLUSTER_NAME="$KIND_CLUSTER_NAME"

# Database connection
export DATABASE_URL="postgres://hyperfleet:$POSTGRES_PASSWORD@localhost:5432/hyperfleet_dev"

# Message broker connection
export BROKER_URL="amqp://hyperfleet:$RABBITMQ_PASSWORD@localhost:5672/"

# Development settings
export LOG_LEVEL="debug"
export DEBUG="true"

# Helpful aliases
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias klogs="kubectl logs -f"

# HyperFleet specific
alias hf-db-port="kubectl port-forward service/postgres-dev 5432:5432"
alias hf-mq-port="kubectl port-forward service/rabbitmq-dev 15672:15672"
alias hf-workspace="cd \$HOME/workspace/hyperfleet"

echo "HyperFleet development environment loaded"
echo "Workspace: \$HOME/workspace/hyperfleet"
echo "Database URL: \$DATABASE_URL"
echo "Broker URL: \$BROKER_URL"
EOF

    print_success "Environment configuration created at ~/.hyperfleet-dev.env"
    echo "To load environment: source ~/.hyperfleet-dev.env"
}

display_summary() {
    echo
    echo "=================================="
    echo "🎉 Setup Complete!"
    echo "=================================="
    echo
    echo "Your HyperFleet development environment is ready:"
    echo
    echo "📱 Kubernetes cluster: $KIND_CLUSTER_NAME"
    echo "🗄️  Database: PostgreSQL (user: hyperfleet, db: hyperfleet_dev)"
    echo "📨 Message broker: RabbitMQ (user: hyperfleet)"
    echo "📂 Workspace: $HOME/workspace/hyperfleet"
    echo
    echo "🚀 Next steps:"
    echo "1. Load environment: source ~/.hyperfleet-dev.env"
    echo "2. Start port forwarding for database:"
    echo "   kubectl port-forward service/postgres-dev 5432:5432 &"
    echo "3. Start port forwarding for RabbitMQ management:"
    echo "   kubectl port-forward service/rabbitmq-dev 15672:15672 &"
    echo "4. Run validation: ./scripts/validate-environment.sh"
    echo
    echo "📚 Continue with: docs/individuals/03-architecture-overview.md"
    echo
    echo "❓ Need help? Ask in #hyperfleet-dev or contact your onboarding buddy"
}

# Main execution
main() {
    echo "🚀 HyperFleet Development Environment Setup"
    echo "=========================================="
    echo

    check_prerequisites
    create_kind_cluster
    install_operators
    setup_database
    setup_message_broker
    clone_repositories
    setup_container_registry_access
    create_env_file
    display_summary
}

# Run main function
main "$@"