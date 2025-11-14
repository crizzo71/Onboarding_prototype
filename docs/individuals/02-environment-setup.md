# Environment Setup Guide

This guide helps you set up your local development environment for HyperFleet development.

## 🎯 Setup Goals

By completing this guide, you'll have:
- [ ] Local Kubernetes cluster (Kind) with HyperFleet components
- [ ] Development tools and IDE configured
- [ ] Git configuration with commit signing
- [ ] Access to container registries and package repositories
- [ ] Validated working environment

## ⚡ Quick Setup Script

For experienced developers, run our automated setup script:

```bash
# Clone this repository first
git clone https://github.com/openshift-hyperfleet/hyperfleet-onboarding.git
cd hyperfleet-onboarding

# Run automated setup
./scripts/setup-dev-environment.sh

# Validate environment
./scripts/validate-environment.sh
```

**Prefer manual setup?** Continue with the detailed guide below.

## 🛠️ Prerequisites

### Required Software

Install these tools before proceeding:

```bash
# macOS (using Homebrew)
brew install git docker kubectl kind helm go jq yq

# Linux (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install git docker.io kubectl
# Install kind, helm, go separately via official docs

# Verify installations
docker --version
kubectl version --client
kind --version
go version
```

### Container Runtime
- **Docker Desktop** (macOS/Windows) or **Podman** (Linux)
- Ensure Docker daemon is running: `docker ps`

### IDE/Editor Setup

**VS Code (Recommended)**
```bash
# Install VS Code extensions
code --install-extension golang.Go
code --install-extension ms-vscode.vscode-yaml
code --install-extension redhat.vscode-kubernetes-tools
code --install-extension ms-vscode.docker
```

**GoLand/IntelliJ** also work well for Go development.

## 🔧 Git Configuration

### Basic Git Setup
```bash
# Set your identity (use Red Hat email)
git config --global user.name "Your Full Name"
git config --global user.email "your.email@redhat.com"

# Configure line endings
git config --global core.autocrlf input  # Linux/Mac
git config --global core.autocrlf true   # Windows
```

### Commit Signing (Required for Production)
```bash
# Generate GPG key
gpg --full-generate-key
# Select: RSA, 4096 bits, no expiration, use Red Hat email

# Find your key ID
gpg --list-secret-keys --keyid-format LONG
# Copy the key ID from sec line

# Configure Git to use GPG
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# Add to GitHub
gpg --armor --export YOUR_KEY_ID
# Copy output and add to GitHub Settings > SSH and GPG keys
```

### Pre-commit Hooks Setup
```bash
# Install pre-commit
pip install pre-commit

# Navigate to HyperFleet repository
cd /path/to/hyperfleet-repo

# Install hooks
pre-commit install

# Test hooks
pre-commit run --all-files
```

## 🏗️ Local Kubernetes Cluster

### Create Kind Cluster
```bash
# Create cluster with HyperFleet configuration
cat << EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: hyperfleet-dev
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

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### Install Required Operators
```bash
# Install Prometheus Operator (for monitoring)
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

# Install cert-manager (for TLS certificates)
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for operators to be ready
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
```

## 📦 Container Registry Access

### Quay.io Access (Red Hat)
```bash
# Login to Red Hat's container registry
docker login quay.io
# Enter your Red Hat credentials

# Test access
docker pull quay.io/openshift-hyperfleet/hyperfleet-api:latest
```

### Internal Artifactory Access
```bash
# Configure internal package registry
# (Instructions will be provided by your manager)

# Test Go module access
go env -w GOPROXY=https://artifactory.redhat.com/go-proxy,direct
```

## 🔍 HyperFleet Local Development

### Clone HyperFleet Repositories
```bash
# Create workspace directory
mkdir -p ~/workspace/hyperfleet
cd ~/workspace/hyperfleet

# Clone main repositories
git clone https://github.com/openshift-hyperfleet/hyperfleet-api.git
git clone https://github.com/openshift-hyperfleet/hyperfleet-sentinel.git
git clone https://github.com/openshift-hyperfleet/hyperfleet-adapter.git
git clone https://github.com/openshift-hyperfleet/hyperfleet-broker.git
git clone https://github.com/openshift-hyperfleet/architecture.git

# Install dependencies for each component
for repo in hyperfleet-*; do
  cd $repo
  if [ -f go.mod ]; then
    go mod download
  elif [ -f requirements.txt ]; then
    pip install -r requirements.txt
  fi
  cd ..
done
```

### Local Development Database
```bash
# Start PostgreSQL for HyperFleet API
kubectl apply -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-dev
  namespace: default
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
          value: development-password
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-dev
spec:
  selector:
    app: postgres-dev
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF

# Wait for database to be ready
kubectl wait --for=condition=available deployment/postgres-dev
```

### Message Broker Setup
```bash
# Install RabbitMQ for local message broker
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq-dev bitnami/rabbitmq \
  --set auth.username=hyperfleet \
  --set auth.password=development \
  --set persistence.enabled=false

# Get connection details
kubectl get secret --namespace default rabbitmq-dev -o jsonpath="{.data.rabbitmq-password}" | base64 --decode
```

## ✅ Environment Validation

### Automated Validation
```bash
# Run our validation script
./scripts/validate-environment.sh

# Expected output:
# ✅ Docker is running
# ✅ Kubernetes cluster accessible
# ✅ Required operators installed
# ✅ Database connectivity
# ✅ Message broker connectivity
# ✅ Container registry access
# ✅ Git configuration complete
```

### Manual Verification
```bash
# Test Kubernetes access
kubectl get pods --all-namespaces

# Test database connection
kubectl port-forward service/postgres-dev 5432:5432 &
psql -h localhost -U hyperfleet -d hyperfleet_dev
# Enter password: development-password

# Test RabbitMQ management UI
kubectl port-forward service/rabbitmq-dev 15672:15672 &
# Open http://localhost:15672 (user: hyperfleet, pass: development)
```

## 🚀 First Build Test

### Build HyperFleet API
```bash
cd ~/workspace/hyperfleet/hyperfleet-api

# Build the application
go build -o bin/hyperfleet-api ./cmd/api

# Run tests
go test ./...

# Start local development server
export DATABASE_URL="postgres://hyperfleet:development-password@localhost:5432/hyperfleet_dev"
export BROKER_URL="amqp://hyperfleet:development@localhost:5672/"
./bin/hyperfleet-api
```

### Verify API is Running
```bash
# In another terminal
curl http://localhost:8080/health
# Expected: {"status": "healthy"}

curl http://localhost:8080/v1/clusters
# Expected: {"clusters": []}
```

## 🔧 Common Issues & Troubleshooting

### Issue: Docker Permission Denied
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Log out and log back in

# Or use Podman as alternative
alias docker=podman
```

### Issue: Kind Cluster Won't Start
```bash
# Clean up and retry
kind delete cluster --name hyperfleet-dev
docker system prune -f

# Recreate cluster
kind create cluster --config=kind-config.yaml
```

### Issue: Can't Access Container Registry
```bash
# Check Docker login
docker config ls

# Re-login to quay.io
docker logout quay.io
docker login quay.io
```

### Issue: Database Connection Failed
```bash
# Check if PostgreSQL is running
kubectl get pods -l app=postgres-dev

# Check service endpoint
kubectl get endpoints postgres-dev

# Reset port forward
pkill -f "kubectl port-forward"
kubectl port-forward service/postgres-dev 5432:5432 &
```

## 📝 Development Workflow Tips

### IDE Configuration
- Use workspace settings for consistent formatting
- Configure Go tools (goimports, golint, gofmt)
- Set up debugging configurations for each component

### Local Testing
- Always run tests before committing
- Use `make test-local` for component testing
- Run integration tests against local cluster

### Performance Considerations
- Kind cluster uses local Docker resources
- Monitor resource usage: `docker stats`
- Adjust cluster size based on your machine specs

## 🎉 You're Ready!

If all validations pass, your development environment is ready for HyperFleet development!

**Next steps:**
1. **[Learn the architecture](03-architecture-overview.md)**
2. **[Set up cloud accounts](04-cloud-accounts.md)**
3. **[Make your first contribution](05-first-contribution.md)**

## 💡 Pro Tips

- **Use tmux/screen** for managing multiple terminal sessions
- **Set up shell aliases** for common kubectl commands
- **Create IDE snippets** for common HyperFleet patterns
- **Join the #hyperfleet-dev** Slack channel for real-time help

---

**Need help?** Ask in #hyperfleet-dev or reach out to your onboarding buddy!

*Estimated completion time: 2-4 hours*