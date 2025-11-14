# Contributing to HyperFleet Onboarding

Welcome to the HyperFleet onboarding system! This guide helps team members contribute improvements, updates, and new features to our onboarding process.

## 🎯 **TL;DR - Quick Start**

1. **Found an issue?** Create a GitHub issue with the `onboarding-improvement` label
2. **Want to fix something?** Fork, create branch, make changes, submit PR
3. **Updating docs?** Edit directly and submit PR - no need for issues
4. **Major changes?** Discuss in #hyperfleet-team Slack first

## 📋 **How to Contribute**

### **Small Updates (Documentation, Links, Contact Info)**
```bash
# Quick fixes - no issue needed
git checkout -b fix/update-slack-channels
# Make your changes
git commit -m "Update Slack channel references"
git push origin fix/update-slack-channels
# Create PR
```

### **Improvements and New Features**
```bash
# 1. Create GitHub issue first (use templates below)
# 2. Create feature branch
git checkout -b feature/add-security-training-module
# 3. Make changes, commit, push, create PR
```

## 🏷️ **Issue Types**

Use these labels when creating issues:

### **`documentation-update`** - Content Changes
- Outdated contact information
- Broken links
- Unclear instructions
- Missing prerequisites

**Example:**
> Title: "Update cloud access request URLs"
> Body: "The AWS access portal URL in docs/managers/01-pre-start-checklist.md is outdated"

### **`process-improvement`** - Workflow Changes
- Better automation opportunities
- Streamlined procedures
- Time-saving shortcuts

**Example:**
> Title: "Automate GitHub organization invitations"
> Body: "Managers manually send GitHub invites. We could automate this through the API"

### **`new-feature`** - Additions
- New onboarding modules
- Additional automation
- Integration with new tools

**Example:**
> Title: "Add mobile app development onboarding path"
> Body: "Need specific guidance for mobile developers joining the team"

### **`bug`** - Something Broken
- Scripts that don't work
- Missing files
- Incorrect instructions

**Example:**
> Title: "Setup script fails on M1 Macs"
> Body: "The Docker setup in scripts/setup-dev-environment.sh doesn't work on Apple Silicon"

### **`feedback`** - Based on Real Experience
- Insights from actual onboarding
- New hire suggestions
- Manager feedback

**Example:**
> Title: "Week 1 timeline too aggressive for junior developers"
> Body: "Last 3 junior hires needed 2 weeks for environment setup, not 1 week"

## 🔄 **Types of Changes We Welcome**

### **✅ Always Welcome**
- **Documentation updates** - Fix typos, update links, clarify instructions
- **Contact information** - Update team contacts, Slack channels, email lists
- **Script improvements** - Bug fixes, better error handling, platform compatibility
- **Process refinements** - Based on real onboarding experience
- **Security updates** - Better credential handling, updated dependencies

### **⚠️ Needs Discussion First**
- **Major workflow changes** - Discuss in #hyperfleet-team before implementing
- **New tool integrations** - Consider maintenance burden and team adoption
- **Architectural changes** - Changes affecting multiple components
- **Timeline modifications** - Impact on PRD commitments

### **❌ Generally Not Accepted**
- **Personal preferences** - Unless supported by data or multiple team members
- **Incomplete features** - Ensure new features are fully documented and tested
- **Security compromises** - No shortcuts that reduce security posture

## 📝 **PR Guidelines**

### **PR Title Format**
```
[type]: Brief description

Examples:
docs: Update manager pre-start checklist timeline
feat: Add Windows support to setup scripts
fix: Correct broken links in architecture guide
security: Update dependency versions in validation script
```

### **PR Description Template**
```markdown
## What Changed
Brief description of what you changed and why.

## Type of Change
- [ ] Documentation update
- [ ] Bug fix
- [ ] New feature
- [ ] Process improvement
- [ ] Security update

## Testing Done
- [ ] Tested scripts on my local environment
- [ ] Reviewed all documentation for accuracy
- [ ] Validated external links
- [ ] Ran security scan (if applicable)

## Impact
- Who this affects: [All new hires / Managers / Specific role]
- Risk level: [Low / Medium / High]
- Urgency: [When should this be merged?]

## Related Issues
Fixes #123
Relates to #456
```

### **Review Requirements**
- **Documentation changes**: 1 reviewer (any team member)
- **Script changes**: 2 reviewers (including 1 technical lead)
- **Process changes**: 2 reviewers (including 1 manager)
- **Security changes**: Security team review required

## 🧪 **Testing Your Changes**

### **Before Submitting PR**
```bash
# Test documentation changes
# - Read through modified docs for clarity
# - Check all links work
# - Verify examples are accurate

# Test script changes
./scripts/test-onboarding-process.sh
chmod +x scripts/*.sh  # Ensure executability

# Test automation changes
# - Validate YAML syntax
# - Test with sample data if possible

# Security check
grep -r "password\|secret\|key.*=" . || echo "✅ No credentials"
```

### **Script Testing Checklist**
- [ ] **Runs without errors** on clean environment
- [ ] **Handles missing prerequisites** gracefully
- [ ] **Provides clear error messages**
- [ ] **Includes help/usage information**
- [ ] **Works across platforms** (macOS/Linux minimum)

### **Documentation Testing Checklist**
- [ ] **All links work** and point to current resources
- [ ] **Instructions are accurate** and up-to-date
- [ ] **Examples work** when followed exactly
- [ ] **Prerequisites are clear** and complete
- [ ] **Success criteria are measurable**

## 🏃‍♀️ **Common Quick Fixes**

### **Update Contact Information**
```bash
# Find and replace pattern
find docs/ -name "*.md" -exec sed -i 's/old@email.com/new@email.com/g' {} +

# Update Slack channels
grep -r "#old-channel" docs/ templates/
# Replace with new channel names
```

### **Fix Broken Links**
```bash
# Find HTTP links that might be broken
grep -r "https\?://" docs/ | grep -v "github.com/openshift-hyperfleet"

# Test each link manually or use link checker tool
```

### **Update Prerequisites**
```bash
# Check current software versions
docker --version
kubectl version --client
kind --version

# Update version numbers in documentation
```

### **Add New Team Members**
```bash
# Update contact lists in:
# - docs/individuals/01-getting-started.md
# - docs/managers/01-pre-start-checklist.md
# - DEPLOYMENT.md
```

## 📊 **Continuous Improvement Process**

### **Monthly Reviews**
- **First Monday of each month**: Review open issues and PRs
- **Gather feedback** from recent new hires
- **Update metrics** and success rates
- **Plan improvements** for next month

### **Quarterly Updates**
- **Complete documentation review** - accuracy and relevance
- **Script maintenance** - dependency updates and testing
- **Process evaluation** - timing and effectiveness
- **Team retrospective** - what's working, what's not

### **Annual Overhaul**
- **Major version update** with breaking changes if needed
- **Technology refresh** - new tools and platforms
- **Complete revalidation** - test entire process end-to-end
- **Competitive analysis** - compare with industry best practices

## 🔐 **Security Considerations**

### **When Contributing**
- **Never commit real credentials** - use placeholder values
- **Scan for secrets** before submitting PR
- **Follow least privilege principle** in access instructions
- **Document security implications** of changes
- **Update `.gitignore`** if adding new file types

### **Security Review Required For**
- Changes to access procedures
- New automation with elevated privileges
- Integration with external services
- Updates to credential handling
- Modification of security validation scripts

## 💬 **Getting Help**

### **Quick Questions**
- **#hyperfleet-dev** - Technical questions about scripts or automation
- **#hyperfleet-team** - General process questions
- **DM @onboarding-process-owner** - Urgent issues or guidance

### **Formal Support**
- **GitHub Issues** - Track bugs, improvements, and feature requests
- **Team Meetings** - Discuss during regular team syncs
- **Office Hours** - Weekly onboarding improvement sessions

### **Emergency Changes**
For urgent fixes that can't wait for normal review:
1. **Create emergency PR** with `urgent` label
2. **Tag @hyperfleet-managers** for immediate review
3. **Post in #hyperfleet-team** explaining urgency
4. **Document incident** and plan prevention

## 🏆 **Recognition**

We celebrate contributors who help improve our onboarding:
- **Monthly shoutouts** for significant improvements
- **Onboarding champion** recognition for sustained contributions
- **Team retrospective mentions** for impact on new hire experience

## 📋 **Quick Checklist for Contributors**

Before submitting any change:

- [ ] **Issue exists** (for non-trivial changes)
- [ ] **Branch named appropriately** (`fix/`, `feat/`, `docs/`)
- [ ] **Changes tested** using appropriate checklist above
- [ ] **Documentation updated** if process changed
- [ ] **Security reviewed** if applicable
- [ ] **PR description complete** with impact and testing info

---

## 🎉 **Thank You!**

Every contribution makes HyperFleet onboarding better for future team members. Whether it's fixing a typo or adding a major feature, your effort directly impacts someone's first impression of our team.

**Questions about contributing?** Reach out in #hyperfleet-team or create an issue with the `question` label.

---

*Last updated: November 2025*
*Review schedule: Monthly on first Monday*