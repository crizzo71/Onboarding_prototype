# HyperFleet Onboarding Process Testing Guide

This guide provides multiple approaches to test your onboarding process before deploying it to real new hires.

## 🧪 Testing Approaches

### 1. **Automated Technical Testing**

Start with automated validation of the technical components:

```bash
# Run the comprehensive test suite
./scripts/test-onboarding-process.sh

# Run full integration test (creates/destroys Kind cluster)
./scripts/test-onboarding-process.sh --full-test

# Test individual components
./scripts/validate-environment.sh
```

**What this tests:**
- Documentation accessibility and formatting
- Script syntax and functionality
- GitHub Actions workflow validity
- Security compliance (no hardcoded credentials)
- Performance benchmarks

### 2. **Simulated New Hire Testing**

Create a realistic simulation of the onboarding experience:

#### Option A: Fresh Environment Test
```bash
# Create a fresh test environment
docker run -it --rm ubuntu:22.04 bash

# Inside container, simulate new hire setup
apt update && apt install -y git curl wget
git clone https://github.com/your-org/hyperfleet-onboarding.git
cd hyperfleet-onboarding

# Follow the onboarding guide step-by-step
# Time each major milestone
```

#### Option B: Virtual Machine Test
```bash
# Use a fresh VM or container
# Document time for each step:
# - Environment setup: __ minutes
# - Documentation reading: __ minutes
# - First successful build: __ minutes
# - Access verification: __ minutes
```

### 3. **Role-Playing Tests**

Recruit volunteers from your team to role-play different scenarios:

#### Test Scenario 1: Junior Developer
**Profile:** Limited Kubernetes experience, strong programming background
**Test Focus:**
- How well does documentation explain concepts?
- Are prerequisites clearly stated?
- Is the learning curve appropriate?

#### Test Scenario 2: Senior Developer
**Profile:** Extensive experience, wants to get productive quickly
**Test Focus:**
- Can they skip to advanced sections?
- Is the automation sufficient?
- Are there shortcuts for experienced users?

#### Test Scenario 3: Manager Onboarding
**Profile:** Engineering manager with team management experience
**Test Focus:**
- Are administrative tasks clearly defined?
- Is the timeline realistic?
- Are escalation paths clear?

### 4. **Checklist Validation Testing**

Test the completeness and accuracy of checklists:

```markdown
## IC Onboarding Checklist Test

**Tester:** [Name]
**Date:** [Date]
**Simulated Role:** [SWE/QE/SRE]

### Pre-Start Tasks (Manager)
- [ ] Can all access requests be submitted? (Test with fake data)
- [ ] Are approval workflows documented correctly?
- [ ] Is the timeline realistic for each task?

### Day 1 Tasks
- [ ] Is the Day 1 agenda achievable in one day?
- [ ] Are all meeting links and resources accessible?
- [ ] Is the buddy system process clear?

### Week 1 Tasks
- [ ] Can environment setup be completed in expected time?
- [ ] Is architecture documentation understandable?
- [ ] Are learning objectives measurable?

### Issues Found:
1. [Issue description]
2. [Issue description]

### Recommendations:
1. [Improvement suggestion]
2. [Improvement suggestion]
```

### 5. **Time-Box Testing**

Validate the time estimates in your PRD:

```bash
# Create a timing test script
cat > test-timing.sh << 'EOF'
#!/bin/bash

echo "=== HyperFleet Onboarding Timing Test ==="

# Day 1 Goals (target: complete in 1 day)
start_time=$(date +%s)
echo "Starting Day 1 simulation at $(date)"

# Simulate each task with realistic timing
echo "Task: Welcome meeting (30 min)"
sleep 5  # Simulated time

echo "Task: Team introduction (45 min)"
sleep 3

echo "Task: Documentation review (2 hours)"
sleep 10

# Calculate total time
end_time=$(date +%s)
duration=$(( end_time - start_time ))
echo "Day 1 simulation completed in $duration seconds"
echo "Extrapolated full time: $(( duration * 60 )) minutes"

# Compare against target (8 hours = 28,800 seconds)
if [ $duration -lt 480 ]; then  # 8 minutes = scaled 8 hours
    echo "✅ Day 1 timing looks realistic"
else
    echo "❌ Day 1 may be too ambitious"
fi
EOF

chmod +x test-timing.sh
./test-timing.sh
```

### 6. **Accessibility Testing**

Ensure the onboarding works for different user profiles:

#### Different Operating Systems
- Test on macOS, Linux, and Windows (if applicable)
- Verify all scripts work across platforms
- Check for platform-specific prerequisites

#### Different Experience Levels
- **Beginner**: Can complete setup with minimal background knowledge?
- **Intermediate**: Can navigate efficiently without getting bogged down?
- **Expert**: Can customize and accelerate the process?

#### Different Access Scenarios
- **Remote employee**: All resources accessible without VPN?
- **Different time zones**: Async components work for global team?
- **Contractors**: Process works for non-FTE access levels?

### 7. **Failure Testing**

Test how the process handles common failure scenarios:

```bash
# Test failure handling
cat > test-failures.sh << 'EOF'
#!/bin/bash

echo "=== Testing Failure Scenarios ==="

# Scenario 1: Docker not running
echo "Testing: Docker not available"
if ! docker ps &>/dev/null; then
    echo "✅ Properly detects Docker unavailable"
    echo "✅ Provides clear error message"
else
    echo "⚠️  Cannot test Docker failure (Docker is running)"
fi

# Scenario 2: Network connectivity issues
echo "Testing: Network connectivity problems"
if ! curl -s https://github.com &>/dev/null; then
    echo "✅ Handles network issues gracefully"
else
    echo "ℹ️  Network connectivity is good"
fi

# Scenario 3: Access denied scenarios
echo "Testing: Permission issues"
# Test with read-only directory
mkdir -p /tmp/readonly-test
chmod 444 /tmp/readonly-test
if ! touch /tmp/readonly-test/testfile 2>/dev/null; then
    echo "✅ Permission issues would be detected"
fi
rm -rf /tmp/readonly-test

echo "Test completed"
EOF

chmod +x test-failures.sh
./test-failures.sh
```

### 8. **Security Testing**

Validate security aspects of your onboarding:

```bash
# Run security-focused tests
cat > test-security.sh << 'EOF'
#!/bin/bash

echo "=== Security Testing ==="

# Test 1: Credential scanning
echo "Scanning for hardcoded credentials..."
if grep -r "password\|secret\|key" --include="*.sh" --include="*.md" scripts/ docs/ | grep -E "(=|:)" | head -5; then
    echo "⚠️  Found potential credential references - review manually"
else
    echo "✅ No obvious credential exposure"
fi

# Test 2: Environment variable usage
echo "Checking environment variable patterns..."
if grep -r '\${[A-Z_]*}' scripts/ | head -3; then
    echo "✅ Proper environment variable usage found"
fi

# Test 3: Sensitive file exclusion
echo "Checking .gitignore for security patterns..."
if test -f .gitignore && grep -q "env\|secret\|credential" .gitignore; then
    echo "✅ .gitignore includes security exclusions"
else
    echo "⚠️  .gitignore may need security patterns"
fi

# Test 4: Script permissions
echo "Checking script permissions..."
find scripts/ -name "*.sh" -executable | while read script; do
    echo "✅ $script is executable"
done

echo "Security testing completed"
EOF

chmod +x test-security.sh
./test-security.sh
```

## 📊 Testing Metrics to Track

### Quantitative Metrics
- **Setup time**: How long does environment setup actually take?
- **Error rate**: What percentage of steps fail on first attempt?
- **Completion rate**: What percentage of testers complete each milestone?
- **Time to productivity**: How long to first successful build/test?

### Qualitative Feedback
- **Clarity**: Are instructions clear and unambiguous?
- **Completeness**: Are any steps missing or unclear?
- **Difficulty**: Is the learning curve appropriate?
- **Support**: Are help resources adequate?

## 🚀 Running Your First Test

### Quick Start Test (30 minutes)
```bash
# 1. Run automated tests
./scripts/test-onboarding-process.sh

# 2. Walk through documentation
time cat docs/individuals/01-getting-started.md

# 3. Test one script
./scripts/validate-environment.sh

# 4. Review GitHub templates
cat templates/github-issues/new-ic-onboarding.yml
```

### Comprehensive Test (2-4 hours)
```bash
# 1. Full automated test suite
./scripts/test-onboarding-process.sh --full-test

# 2. Simulated new hire experience
# Follow docs/individuals/ guides step by step

# 3. Manager workflow test
# Follow docs/managers/ guides

# 4. Failure scenario testing
# Intentionally break things and test recovery

# 5. Document findings and improvements needed
```

## 📝 Test Report Template

```markdown
# Onboarding Process Test Report

**Date:** [Date]
**Tester:** [Name and Role]
**Test Type:** [Quick/Comprehensive/Role-specific]

## Summary
[Overall assessment of onboarding quality]

## Timing Results
- Environment setup: __ minutes (target: X minutes)
- Documentation review: __ minutes (target: X minutes)
- First successful build: __ minutes (target: X minutes)

## Issues Found
1. **[Issue Title]**
   - Severity: High/Medium/Low
   - Description: [What went wrong]
   - Suggested fix: [How to improve]

2. **[Issue Title]**
   - [Continue for each issue]

## Positive Feedback
- [What worked well]
- [Particularly clear instructions]
- [Helpful automation]

## Recommendations
1. [Priority improvement]
2. [Nice-to-have improvement]
3. [Long-term enhancement]

## Overall Rating
- **Technical Setup:** ⭐⭐⭐⭐⭐ (X/5)
- **Documentation Quality:** ⭐⭐⭐⭐⭐ (X/5)
- **Process Clarity:** ⭐⭐⭐⭐⭐ (X/5)
- **Support Resources:** ⭐⭐⭐⭐⭐ (X/5)

**Ready for production?** Yes/No - [Explanation]
```

## 🎯 Success Criteria

Your onboarding process is ready for production when:

- [ ] **95%+ automated tests pass**
- [ ] **All role-playing testers can complete their scenarios**
- [ ] **Timing targets are met within 20% variance**
- [ ] **No critical security issues found**
- [ ] **Documentation is clear to newcomers**
- [ ] **Failure scenarios are handled gracefully**
- [ ] **Feedback is overwhelmingly positive (4+ stars)**

Start with the automated testing script, then progressively test with real people to validate the human experience!