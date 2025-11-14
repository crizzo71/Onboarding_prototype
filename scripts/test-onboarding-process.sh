#!/bin/bash

# HyperFleet Onboarding Process Testing Script
# Tests the entire onboarding automation and validation pipeline
#
# Usage: ./scripts/test-onboarding-process.sh [--full-test]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_MODE="basic"
if [[ "${1:-}" == "--full-test" ]]; then
    TEST_MODE="full"
fi

print_test_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_failure() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test tracking
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing $test_name... "

    if eval "$test_command" &> /dev/null; then
        print_success "PASS"
        ((TESTS_PASSED++))
    else
        print_failure "FAIL"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Documentation Accessibility
test_documentation() {
    print_test_header "Documentation Testing"

    run_test "README.md exists and readable" "test -r README.md"
    run_test "Getting started guide exists" "test -r docs/individuals/01-getting-started.md"
    run_test "Environment setup guide exists" "test -r docs/individuals/02-environment-setup.md"
    run_test "Manager checklist exists" "test -r docs/managers/01-pre-start-checklist.md"
    run_test "GitHub issue templates exist" "test -r templates/github-issues/new-ic-onboarding.yml"

    # Test for broken links (basic check)
    echo "Checking for obvious broken links..."
    if grep -r "](http" docs/ --include="*.md" | grep -q "404\|broken"; then
        print_failure "Found potential broken links"
        ((TESTS_FAILED++))
    else
        print_success "No obvious broken links found"
        ((TESTS_PASSED++))
    fi
}

# Test 2: Script Functionality
test_scripts() {
    print_test_header "Script Testing"

    run_test "Setup script is executable" "test -x scripts/setup-dev-environment.sh"
    run_test "Validation script is executable" "test -x scripts/validate-environment.sh"

    # Test setup script dry run (if implemented)
    echo "Testing setup script syntax..."
    if bash -n scripts/setup-dev-environment.sh; then
        print_success "Setup script syntax valid"
        ((TESTS_PASSED++))
    else
        print_failure "Setup script has syntax errors"
        ((TESTS_FAILED++))
    fi

    # Test validation script syntax
    echo "Testing validation script syntax..."
    if bash -n scripts/validate-environment.sh; then
        print_success "Validation script syntax valid"
        ((TESTS_PASSED++))
    else
        print_failure "Validation script has syntax errors"
        ((TESTS_FAILED++))
    fi
}

# Test 3: GitHub Integration
test_github_integration() {
    print_test_header "GitHub Integration Testing"

    run_test "GitHub Actions workflow exists" "test -r .github/workflows/onboarding-automation.yml"
    run_test "IC onboarding template is valid YAML" "python3 -c 'import yaml; yaml.safe_load(open(\"templates/github-issues/new-ic-onboarding.yml\"))'"
    run_test "Manager onboarding template is valid YAML" "python3 -c 'import yaml; yaml.safe_load(open(\"templates/github-issues/new-manager-onboarding.yml\"))'"

    # Test GitHub Actions workflow syntax
    if command -v yamllint &> /dev/null; then
        echo "Validating GitHub Actions workflow..."
        if yamllint .github/workflows/onboarding-automation.yml; then
            print_success "GitHub Actions workflow valid"
            ((TESTS_PASSED++))
        else
            print_failure "GitHub Actions workflow has issues"
            ((TESTS_FAILED++))
        fi
    else
        print_warning "yamllint not available, skipping workflow validation"
    fi
}

# Test 4: Environment Setup Simulation
test_environment_setup() {
    print_test_header "Environment Setup Simulation"

    # Create a temporary test directory
    local test_dir="/tmp/hyperfleet-onboarding-test-$$"
    mkdir -p "$test_dir"

    echo "Testing in isolation: $test_dir"

    # Test prerequisites checking function
    echo "Testing prerequisite checks..."

    # Test Docker availability
    if command -v docker &> /dev/null; then
        if docker ps &> /dev/null; then
            print_success "Docker is available and running"
            ((TESTS_PASSED++))
        else
            print_warning "Docker installed but not running"
        fi
    else
        print_warning "Docker not available for testing"
    fi

    # Test kubectl availability
    if command -v kubectl &> /dev/null; then
        print_success "kubectl is available"
        ((TESTS_PASSED++))
    else
        print_warning "kubectl not available for testing"
    fi

    # Test kind availability
    if command -v kind &> /dev/null; then
        print_success "kind is available"
        ((TESTS_PASSED++))
    else
        print_warning "kind not available for testing"
    fi

    # Clean up
    rm -rf "$test_dir"
}

# Test 5: Content Quality Check
test_content_quality() {
    print_test_header "Content Quality Testing"

    # Test for placeholder content
    echo "Checking for placeholder content..."
    if grep -r "\[TODO\]\|\[PLACEHOLDER\]\|\[FILL IN\]" docs/ --include="*.md"; then
        print_failure "Found placeholder content that needs completion"
        ((TESTS_FAILED++))
    else
        print_success "No placeholder content found"
        ((TESTS_PASSED++))
    fi

    # Test for consistent formatting
    echo "Checking markdown formatting consistency..."
    local formatting_issues=0

    # Check for consistent header levels
    if find docs/ -name "*.md" -exec grep -l "^####" {} \; | head -1; then
        print_warning "Found level 4 headers - consider restructuring for better hierarchy"
    fi

    # Check for TODO items in documentation
    if grep -r "TODO\|FIXME\|XXX" docs/ --include="*.md"; then
        print_warning "Found TODO items in documentation"
    else
        print_success "No TODO items in documentation"
        ((TESTS_PASSED++))
    fi
}

# Test 6: Security Compliance Check
test_security_compliance() {
    print_test_header "Security Compliance Testing"

    # Check for hardcoded credentials
    echo "Scanning for hardcoded credentials..."
    local credential_patterns=(
        "password\s*=\s*[\"'][^\"']+[\"']"
        "api_key\s*=\s*[\"'][^\"']+[\"']"
        "secret\s*=\s*[\"'][^\"']+[\"']"
        "token\s*=\s*[\"'][^\"']+[\"']"
    )

    local found_credentials=false
    for pattern in "${credential_patterns[@]}"; do
        if grep -r -E "$pattern" scripts/ docs/ --include="*.sh" --include="*.md" --include="*.yml"; then
            found_credentials=true
        fi
    done

    if [ "$found_credentials" = true ]; then
        print_failure "Found potential hardcoded credentials"
        ((TESTS_FAILED++))
    else
        print_success "No hardcoded credentials found"
        ((TESTS_PASSED++))
    fi

    # Check for proper environment variable usage
    echo "Checking environment variable patterns..."
    if grep -r '\${[A-Z_]*}' scripts/ --include="*.sh" | head -5; then
        print_success "Found proper environment variable usage"
        ((TESTS_PASSED++))
    fi

    # Check for .gitignore security
    if test -f .gitignore; then
        if grep -q "\.env$\|credentials\|secrets" .gitignore; then
            print_success ".gitignore includes security patterns"
            ((TESTS_PASSED++))
        else
            print_warning ".gitignore missing security exclusions"
        fi
    fi
}

# Test 7: Performance Testing (Basic)
test_performance() {
    print_test_header "Performance Testing"

    # Test documentation load time
    echo "Testing documentation accessibility performance..."
    local start_time=$(date +%s%N)

    # Simulate reading all documentation
    find docs/ -name "*.md" -exec wc -l {} \; > /dev/null

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds

    if [ $duration -lt 1000 ]; then
        print_success "Documentation loads quickly ($duration ms)"
        ((TESTS_PASSED++))
    else
        print_warning "Documentation loading is slow ($duration ms)"
    fi

    # Test script execution time
    echo "Testing script parsing performance..."
    start_time=$(date +%s%N)
    bash -n scripts/setup-dev-environment.sh
    bash -n scripts/validate-environment.sh
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))

    if [ $duration -lt 500 ]; then
        print_success "Scripts parse quickly ($duration ms)"
        ((TESTS_PASSED++))
    else
        print_warning "Script parsing is slow ($duration ms)"
    fi
}

# Test 8: Full Integration Test (Optional)
test_full_integration() {
    if [ "$TEST_MODE" != "full" ]; then
        print_warning "Skipping full integration test (use --full-test to enable)"
        return
    fi

    print_test_header "Full Integration Testing"

    echo "WARNING: This will create and destroy a Kind cluster"
    echo "Press Enter to continue or Ctrl+C to cancel..."
    read

    # Test the actual setup process
    echo "Running setup script in test mode..."
    if ./scripts/setup-dev-environment.sh --dry-run 2>/dev/null; then
        print_success "Setup script dry run successful"
        ((TESTS_PASSED++))
    else
        # If no dry-run support, run validation
        echo "Testing validation script..."
        if ./scripts/validate-environment.sh; then
            print_success "Validation script runs successfully"
            ((TESTS_PASSED++))
        else
            print_failure "Validation script failed"
            ((TESTS_FAILED++))
        fi
    fi
}

# Main test execution
main() {
    echo "🧪 HyperFleet Onboarding Process Testing"
    echo "========================================"
    echo "Test mode: $TEST_MODE"
    echo

    test_documentation
    test_scripts
    test_github_integration
    test_environment_setup
    test_content_quality
    test_security_compliance
    test_performance
    test_full_integration

    # Results summary
    echo
    echo "=================================="
    echo "📊 Test Results Summary"
    echo "=================================="
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Onboarding process is ready for pilot testing.${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Please address issues before proceeding.${NC}"
        echo
        echo "Next steps:"
        echo "1. Fix any failed tests"
        echo "2. Re-run testing: $0"
        echo "3. Consider pilot testing with volunteer team member"
        return 1
    fi
}

# Run the tests
main "$@"