# Manager Pre-Start Checklist

**Timeline: Complete T-5 business days before new hire start date**

This guide ensures all administrative and access preparation is complete before your new team member's first day, enabling them to be productive immediately upon arrival.

## 🎯 Pre-Start Objectives

By completing this checklist, you ensure:
- [ ] All access requests are submitted and processing
- [ ] New hire has clear Day 1 expectations and agenda
- [ ] Team is prepared to welcome and support new team member
- [ ] Administrative systems are updated
- [ ] Onboarding buddy is assigned and briefed

## 📋 Access Provisioning (T-5 days)

### GitHub Organization Access
- [ ] **Send GitHub invitation** to openshift-hyperfleet organization
  ```bash
  # Process
  1. Go to https://github.com/orgs/openshift-hyperfleet/people
  2. Click "Invite member"
  3. Enter new hire's GitHub username or email
  4. Assign to appropriate teams:
     - hyperfleet-core (all team members)
     - hyperfleet-[role] (swe/qe/sre specific)
     - hyperfleet-managers (if manager)
  ```

### Cloud Account Requests
- [ ] **AWS Account Access**
  ```
  Request through: [Internal AWS Access Portal]
  Account Type: Development (immediate), Staging (Week 1), Production (Month 2)
  Justification: New HyperFleet team member onboarding
  Approval Required: Your manager + Cloud Security team
  ```

- [ ] **GCP Project Access**
  ```
  Request through: [Internal GCP Access Portal]
  Projects: hyperfleet-dev, hyperfleet-staging
  Role: Editor (development), Viewer (staging initially)
  Service Account: Auto-create personal SA
  ```

- [ ] **Azure Subscription Access** (if working on ARO)
  ```
  Request through: [Internal Azure Portal]
  Subscription: hyperfleet-dev-subscription
  Role: Contributor
  Resource Groups: hyperfleet-dev-rg
  ```

### VPN and Network Access
- [ ] **VPN Access Request**
  ```
  System: Red Hat VPN (if required for staging/prod access)
  Duration: Permanent (employee)
  Justification: HyperFleet team member - requires access to staging systems
  ```

### Container Registry Access
- [ ] **Quay.io Access**
  ```
  Organization: openshift-hyperfleet
  Permissions: Read (immediate), Write (Week 2)
  Teams: hyperfleet-developers
  ```

## 🏢 Administrative Setup (T-5 days)

### HR and People Systems
- [ ] **Update org chart** in org-as-code repository
  ```bash
  # Update file: org/hyperfleet/team-structure.yaml
  # Add new team member under your reporting structure
  # Submit PR with manager approval required
  ```

- [ ] **Budget allocation** adjustment
  ```
  Update quarterly headcount planning
  Adjust team budget for new hire
  Update capacity planning models
  ```

- [ ] **Seat licensing** requests
  ```
  Slack: Add to workspace
  Zoom: Assign license if presenter role needed
  Jira: Add to hyperfleet projects
  Confluence: Add to team spaces
  ```

### Team Structure Updates
- [ ] **Email distribution lists**
  ```
  Add to: hyperfleet-team@redhat.com
  Add to: hyperfleet-[role]@redhat.com
  Add to: hyperfleet-managers@redhat.com (if manager)
  ```

- [ ] **Calendar permissions**
  ```
  Share: HyperFleet Team Calendar
  Share: Manager 1:1 Calendar
  Invite to: Regular team ceremonies
  ```

## 👥 Onboarding Support Assignment (T-3 days)

### Onboarding Buddy Selection
- [ ] **Identify appropriate buddy**
  ```
  Criteria:
  ✓ Same role type (SWE/QE/SRE)
  ✓ 6+ months on team
  ✓ Strong technical and cultural knowledge
  ✓ Available for daily support first week
  ✓ Willing to be mentor/guide
  ```

- [ ] **Brief onboarding buddy**
  ```
  Share: New hire background and experience level
  Provide: Onboarding buddy guide and expectations
  Schedule: Buddy preparation meeting
  Confirm: Availability for first 2 weeks
  ```

### Team Preparation
- [ ] **Announce new hire** to team
  ```
  Channel: #hyperfleet-team
  Include: Background, role, start date, buddy assignment
  Request: Team to prepare welcoming environment
  ```

- [ ] **Prepare team introductions**
  ```
  Schedule: Team introduction session (Day 1)
  Prepare: Team overview presentation
  Plan: Role-by-role team member introductions
  ```

## 📧 Communication Setup (T-2 days)

### Welcome Email Creation
- [ ] **Send welcome email** to new hire
  ```
  Subject: Welcome to HyperFleet! Your Day 1 Agenda
  Include:
  - Day 1 schedule and meeting links
  - Badge/building access instructions
  - Parking information
  - Contact information for questions
  - Links to getting started documentation
  ```

### Day 1 Agenda Preparation
- [ ] **Schedule Day 1 meetings**
  ```
  9:00 AM - Welcome & Logistics (30 min)
  9:45 AM - Team Introduction (45 min)
  11:00 AM - Onboarding Buddy Introduction (30 min)
  2:00 PM - IT Setup & Account Verification (60 min)
  3:30 PM - Getting Started Documentation Review (60 min)
  4:30 PM - Day 1 Wrap-up & Day 2 Planning (30 min)
  ```

### Slack Channel Setup
- [ ] **Prepare Slack channel invitations**
  ```
  Essential:
  - #hyperfleet-team
  - #hyperfleet-dev
  - #hyperfleet-announcements
  - #hyperfleet-incidents (Week 2)
  - #hyperfleet-social (optional)

  Role-specific:
  - #hyperfleet-swe (Software Engineers)
  - #hyperfleet-qe (Quality Engineers)
  - #hyperfleet-sre (Site Reliability Engineers)
  ```

## 🔧 Technical Preparation (T-1 day)

### Development Environment Prep
- [ ] **Validate setup scripts** are current
  ```bash
  # Test the automated setup script
  ./scripts/setup-dev-environment.sh --dry-run

  # Update any outdated dependencies or configurations
  # Test validation script
  ./scripts/validate-environment.sh
  ```

### Access Request Status Check
- [ ] **Verify access request status**
  ```
  GitHub: ✓ Invitation sent, pending acceptance
  AWS: ✓ Request approved, access active Day 1
  GCP: ✓ Projects added, SA created
  VPN: ✓ Credentials ready for pickup
  Quay.io: ✓ Organization invitation pending
  ```

### Documentation Validation
- [ ] **Review onboarding documentation** for accuracy
  ```
  Verify: All links work and content is current
  Update: Any outdated process or contact information
  Confirm: Architecture documentation reflects current state
  ```

## 📊 Onboarding Issue Creation

### GitHub Issue Setup
- [ ] **Create onboarding issue** using template
  ```bash
  # Go to: hyperfleet-onboarding repository
  # Use: templates/github-issues/new-ic-onboarding.yml
  # Fill in: Name, start date, role, buddy assignment
  # Assign: Yourself, onboarding buddy, new hire (when they have access)
  # Labels: onboarding, individual-contributor, [role-specific]
  ```

### Tracking Setup
- [ ] **Set up progress tracking**
  ```
  Add to: Onboarding project board
  Configure: Automated reminders for incomplete tasks
  Schedule: Weekly progress review meetings
  ```

## ⚠️ Common Pre-Start Pitfalls

### Timing Issues
- **❌ Late access requests:** Cloud access can take 3-5 business days
- **✅ Solution:** Submit all access requests T-5 days minimum

### Communication Gaps
- **❌ New hire doesn't know where to go:** No clear Day 1 instructions
- **✅ Solution:** Send detailed welcome email with logistics

### Team Preparation
- **❌ Team is surprised:** No announcement or preparation
- **✅ Solution:** Brief team at least 3 days before start date

### Buddy Unavailability
- **❌ Buddy is unavailable:** Key meetings or PTO during onboarding
- **✅ Solution:** Confirm buddy availability before assignment

## 📞 Escalation Contacts

### For Access Issues
- **GitHub:** @github-admins in #hyperfleet-dev
- **Cloud Platforms:** IT Security team via [ticketing system]
- **VPN:** IT Support via [support portal]

### For Process Questions
- **Onboarding Process:** @onboarding-process-owner
- **HR Questions:** HR Business Partner
- **Budget/Headcount:** Your manager

## ✅ Pre-Start Completion Checklist

Before new hire's start date, verify:

- [ ] **All access requests submitted** (and most approved)
- [ ] **Team is prepared** and aware of new hire
- [ ] **Onboarding buddy assigned** and briefed
- [ ] **Day 1 agenda created** and shared
- [ ] **Welcome email sent** with logistics
- [ ] **GitHub onboarding issue created**
- [ ] **Documentation validated** and current
- [ ] **Manager calendar cleared** for Day 1 availability

## 🎯 Success Metrics

Your pre-start preparation is successful when:
- New hire has clear expectations and agenda for Day 1
- All critical access is available by Day 1 (or processing with clear timelines)
- Team is prepared to welcome and support new team member
- Onboarding buddy is ready and available
- No administrative delays impact first-week productivity

---

**Next:** [Day One Checklist →](02-day-one-checklist.md)

*Estimated time investment: 2-3 hours spread over 5 days*