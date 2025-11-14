#!/bin/bash

# HyperFleet Development Environment Validation Script
# This script validates that your development environment is correctly configured
#
# Usage: ./scripts/validate-environment.sh

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

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Helper functions
print_test() {
    echo -n "Testing $1... "
}

pass_test() {
    echo -e "${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
}

fail_test() {
    echo -e "${RED}❌ FAIL${NC}"
    if [ $# -gt 0 ]; then
        echo -e "   ${RED}↳ $1${NC}"
    fi
    ((TESTS_FAILED++))
    FAILED_TESTS+=("$2")
}

warn_test() {
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    if [ $# -gt 0 ]; then
        echo -e "   ${YELLOW}↳ $1${NC}"
    fi
}

# Test functions
test_docker() {
    print_test "Docker daemon"
    if docker ps &> /dev/null; then
        pass_test
    else
        fail_test "Docker is not running or not accessible" "docker"
    fi
}

test_kubectl() {
    print_test "kubectl access"
    if kubectl cluster-info &> /dev/null; then
        pass_test
    else
        fail_test "Cannot connect to Kubernetes cluster" "kubectl"
    fi
}

test_kind_cluster() {
    print_test "Kind cluster ($KIND_CLUSTER_NAME)"
    if kind get clusters | grep -q "$KIND_CLUSTER_NAME"; then
        if kubectl get nodes &> /dev/null; then
            pass_test
        else
            fail_test "Cluster exists but is not accessible" "kind-access"
        fi
    else
        fail_test "Cluster $KIND_CLUSTER_NAME does not exist" "kind-cluster"
    fi
}

test_required_tools() {
    local tools=("git" "go" "helm" "jq" "yq")

    for tool in "${tools[@]}"; do
        print_test "$tool installation"
        if command -v "$tool" &> /dev/null; then
            pass_test
        else
            fail_test "$tool is not installed" "tool-$tool"
        fi
    done
}

test_cert_manager() {
    print_test "cert-manager installation"
    if kubectl get namespace cert-manager &> /dev/null; then
        if kubectl get deployment cert-manager -n cert-manager &> /dev/null; then
            if kubectl get deployment cert-manager -n cert-manager -o jsonpath='{.status.readyReplicas}' | grep -q "1"; then
                pass_test
            else
                fail_test "cert-manager deployment is not ready" "cert-manager-ready"
            fi
        else
            fail_test "cert-manager deployment not found" "cert-manager-deployment"
        fi
    else
        fail_test "cert-manager namespace not found" "cert-manager-namespace"
    fi
}

test_postgres() {
    print_test "PostgreSQL deployment"
    if kubectl get deployment postgres-dev &> /dev/null; then
        if kubectl get deployment postgres-dev -o jsonpath='{.status.readyReplicas}' | grep -q "1"; then
            pass_test
        else
            fail_test "PostgreSQL deployment is not ready" "postgres-ready"
        fi
    else
        fail_test "PostgreSQL deployment not found" "postgres-deployment"
    fi
}

test_postgres_connectivity() {
    print_test "PostgreSQL connectivity"

    # Start port forwarding in background
    local port_forward_pid
    kubectl port-forward service/postgres-dev 5432:5432 &> /dev/null &
    port_forward_pid=$!

    # Wait a moment for port forward to establish
    sleep 2

    # Test connection using psql if available, otherwise use simple TCP test
    if command -v psql &> /dev/null; then
        if PGPASSWORD="$POSTGRES_PASSWORD" psql -h localhost -U hyperfleet -d hyperfleet_dev -c "SELECT 1;" &> /dev/null; then
            pass_test
        else
            fail_test "Cannot connect to PostgreSQL database" "postgres-connection"
        fi
    else
        # Use nc or timeout to test TCP connectivity
        if timeout 5 bash -c "</dev/tcp/localhost/5432" &> /dev/null; then
            pass_test
        else
            fail_test "Cannot establish TCP connection to PostgreSQL" "postgres-tcp"
        fi
    fi

    # Clean up port forward
    kill $port_forward_pid &> /dev/null || true
}

test_rabbitmq() {
    print_test "RabbitMQ deployment"
    if kubectl get statefulset rabbitmq-dev &> /dev/null; then
        if kubectl get statefulset rabbitmq-dev -o jsonpath='{.status.readyReplicas}' | grep -q "1"; then
            pass_test
        else
            fail_test "RabbitMQ statefulset is not ready" "rabbitmq-ready"
        fi
    else
        fail_test "RabbitMQ statefulset not found" "rabbitmq-deployment"
    fi
}

test_rabbitmq_connectivity() {
    print_test "RabbitMQ connectivity"

    # Start port forwarding in background
    local port_forward_pid
    kubectl port-forward service/rabbitmq-dev 15672:15672 &> /dev/null &
    port_forward_pid=$!

    # Wait a moment for port forward to establish
    sleep 3

    # Test HTTP connectivity to management interface
    if curl -s -u "hyperfleet:$RABBITMQ_PASSWORD" http://localhost:15672/api/overview &> /dev/null; then
        pass_test
    else
        # Fallback to simple TCP test
        if timeout 5 bash -c "</dev/tcp/localhost/15672" &> /dev/null; then
            warn_test "TCP connection works but authentication may be incorrect"
        else
            fail_test "Cannot connect to RabbitMQ management interface" "rabbitmq-connection"
        fi
    fi

    # Clean up port forward
    kill $port_forward_pid &> /dev/null || true
}

test_git_config() {
    print_test "Git configuration"
    local issues=()

    if ! git config user.name &> /dev/null; then
        issues+=("user.name not set")
    fi

    if ! git config user.email &> /dev/null; then
        issues+=("user.email not set")
    fi

    local email
    email=$(git config user.email 2>/dev/null || echo "")
    if [[ ! "$email" =~ @redhat\.com$ ]]; then
        issues+=("email should be @redhat.com")
    fi

    if [ ${#issues[@]} -eq 0 ]; then
        pass_test
    else
        fail_test "${issues[*]}" "git-config"
    fi
}

test_container_registry() {
    print_test "Container registry access"

    # Test pulling a public image
    if docker pull hello-world:latest &> /dev/null; then
        pass_test
        # Clean up
        docker rmi hello-world:latest &> /dev/null || true
    else
        fail_test "Cannot pull from container registry" "container-registry"
    fi
}

test_workspace() {
    print_test "HyperFleet workspace"
    local workspace_dir="$HOME/workspace/hyperfleet"

    if [ -d "$workspace_dir" ]; then
        local found_repos=0
        for repo in "hyperfleet-api" "hyperfleet-sentinel" "architecture"; do
            if [ -d "$workspace_dir/$repo" ]; then
                ((found_repos++))
            fi
        done

        if [ $found_repos -gt 0 ]; then
            pass_test
        else
            warn_test "Workspace exists but no repositories found"
        fi
    else
        fail_test "Workspace directory not found: $workspace_dir" "workspace"
    fi
}

test_environment_file() {
    print_test "Environment configuration file"

    if [ -f "$HOME/.hyperfleet-dev.env" ]; then
        # Check if it contains expected variables
        if grep -q "DATABASE_URL" "$HOME/.hyperfleet-dev.env" && \
           grep -q "BROKER_URL" "$HOME/.hyperfleet-dev.env"; then
            pass_test
        else
            fail_test "Environment file missing required variables" "env-content"
        fi
    else
        fail_test "Environment file not found: ~/.hyperfleet-dev.env" "env-file"
    fi
}

# Performance tests
test_cluster_resources() {
    print_test "Cluster resource availability"

    local node_count
    node_count=$(kubectl get nodes --no-headers | wc -l)

    if [ "$node_count" -lt 2 ]; then
        warn_test "Only $node_count node(s) available. Consider adding more for realistic testing."
    else
        pass_test
    fi
}

# Display comprehensive results
display_results() {
    echo
    echo "=================================="
    echo "🔍 Validation Results"
    echo "=================================="
    echo
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Your development environment is ready.${NC}"
        echo
        echo "🚀 Next steps:"
        echo "1. Source environment: source ~/.hyperfleet-dev.env"
        echo "2. Start port forwarding:"
        echo "   kubectl port-forward service/postgres-dev 5432:5432 &"
        echo "   kubectl port-forward service/rabbitmq-dev 15672:15672 &"
        echo "3. Continue with: docs/individuals/03-architecture-overview.md"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Please address the following issues:${NC}"
        echo
        for test in "${FAILED_TESTS[@]}"; do
            case $test in
                "docker")
                    echo -e "${RED}•${NC} Start Docker Desktop or ensure Docker daemon is running"
                    ;;
                "kubectl")
                    echo -e "${RED}•${NC} Check your kubeconfig or create a Kind cluster"
                    ;;
                "kind-cluster")
                    echo -e "${RED}•${NC} Run: ./scripts/setup-dev-environment.sh"
                    ;;
                "postgres-deployment")
                    echo -e "${RED}•${NC} Deploy PostgreSQL: kubectl apply -f kubernetes/postgres-dev.yaml"
                    ;;
                "rabbitmq-deployment")
                    echo -e "${RED}•${NC} Deploy RabbitMQ: helm install rabbitmq-dev bitnami/rabbitmq [options]"
                    ;;
                "git-config")
                    echo -e "${RED}•${NC} Configure Git: git config --global user.email 'your.email@redhat.com'"
                    ;;
                "workspace")
                    echo -e "${RED}•${NC} Create workspace: mkdir -p ~/workspace/hyperfleet && cd ~/workspace/hyperfleet"
                    ;;
                "tool-"*)
                    local tool=${test#tool-}
                    echo -e "${RED}•${NC} Install $tool (see setup instructions)"
                    ;;
                *)
                    echo -e "${RED}•${NC} Fix issue: $test"
                    ;;
            esac
        done
        echo
        echo "💡 For help, run: ./scripts/setup-dev-environment.sh"
        return 1
    fi
}

# Main execution
main() {
    echo "🔍 HyperFleet Development Environment Validation"
    echo "============================================="
    echo

    # Core infrastructure tests
    test_docker
    test_kubectl
    test_kind_cluster

    # Required tools
    test_required_tools

    # Kubernetes components
    test_cert_manager
    test_postgres
    test_rabbitmq

    # Connectivity tests
    test_postgres_connectivity
    test_rabbitmq_connectivity

    # Configuration tests
    test_git_config
    test_container_registry
    test_workspace
    test_environment_file

    # Performance considerations
    test_cluster_resources

    # Display results and recommendations
    display_results
}

# Run main function
main "$@"