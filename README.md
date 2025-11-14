# HyperFleet Team Onboarding System

**Version:** 1.0 (Prototype)
**Last Updated:** November 14, 2025
**Organization:** Red Hat - OpenShift HyperFleet (HCM)

## Overview

This repository contains the comprehensive onboarding system for new team members joining the OpenShift HyperFleet project. HyperFleet is a cloud-agnostic cluster lifecycle management framework supporting Red Hat's Hybrid Cloud Management strategy across AWS, GCP, and Azure environments.

## 🎯 Onboarding Goals

- **Time-to-first-PR merged:** ≤ 10 business days
- **New hire satisfaction:** ≥ 4.5/5
- **Zero security incidents** during onboarding
- **100% checklist completion rate**

## 🚀 Quick Start

### For New Individual Contributors (ICs)
👉 **[Start Here: IC Onboarding Guide](docs/individuals/01-getting-started.md)**

### For Engineering Managers
👉 **[Start Here: Manager Onboarding Guide](docs/managers/01-pre-start-checklist.md)**

## 📁 Repository Structure

```
hyperfleet-onboarding/
├── README.md                          # This file
├── docs/
│   ├── individuals/                   # IC onboarding guides
│   │   ├── 01-getting-started.md     # Day 1 orientation
│   │   ├── 02-environment-setup.md   # Dev environment setup
│   │   ├── 03-architecture-overview.md # HyperFleet architecture
│   │   ├── 04-cloud-accounts.md      # AWS/GCP/Azure access
│   │   ├── 05-first-contribution.md  # Making first PR
│   │   └── 06-resources.md           # Reference materials
│   ├── managers/                      # Manager workflows
│   │   ├── 01-pre-start-checklist.md # Pre-arrival tasks
│   │   ├── 02-day-one-checklist.md   # Day 1 manager tasks
│   │   ├── 03-week-one-checklist.md  # Week 1 follow-up
│   │   ├── 04-ongoing-support.md     # 30-60-90 day milestones
│   │   └── 05-org-as-code-updates.md # System updates
│   ├── architecture/                 # Technical deep-dives
│   │   ├── system-overview.md        # High-level architecture
│   │   ├── component-deep-dives/     # Per-component guides
│   │   ├── integration-guides/       # How components interact
│   │   └── diagrams/                 # Architecture diagrams
│   └── runbooks/                     # Troubleshooting guides
│       ├── troubleshooting.md        # Common issues
│       ├── common-errors.md          # FAQ and solutions
│       └── emergency-procedures.md   # Escalation paths
├── scripts/                          # Automation scripts
│   ├── setup-dev-environment.sh     # Local dev setup
│   ├── validate-environment.sh      # Environment validation
│   ├── request-cloud-access.sh      # Cloud access automation
│   └── generate-kubeconfig.sh       # Kubernetes config
├── templates/                        # Reusable templates
│   ├── github-issues/               # Issue templates
│   │   ├── new-ic-onboarding.yml    # IC onboarding issue
│   │   ├── new-manager-onboarding.yml # Manager checklist
│   │   └── access-request.yml       # Access request template
│   ├── checklists/                  # Printable checklists
│   └── documentation/               # Doc templates
└── .github/                         # GitHub automation
    └── workflows/
        ├── onboarding-automation.yml # Automated workflows
        └── checklist-reminder.yml   # Reminder notifications
```

## 🎭 Onboarding Personas

### New Individual Contributor (IC)
- **Roles:** Software Engineer, Quality Engineer, SRE
- **Experience:** Junior (basic K8s) to Senior (multi-cloud architecture)
- **Timeline:** 2 weeks to first meaningful contribution

### Engineering Manager
- **Responsibilities:** Team setup, access provisioning, people management
- **Timeline:** Complete IC setup before their start date

## 🛠️ HyperFleet Technology Stack

New team members will work with:
- **Core:** Kubernetes operators, CloudEvents 1.0, Go/Python
- **Cloud Providers:** AWS (ROSA), GCP, Azure (ARO)
- **Messaging:** GCP Pub/Sub, RabbitMQ
- **Observability:** Prometheus, Grafana, Jaeger
- **CI/CD:** Prow, Tekton, GitHub Actions

## 📊 Success Metrics

We track onboarding effectiveness through:
- Time-to-first-PR completion
- Checklist completion rates
- New hire satisfaction surveys
- Security incident tracking
- Manager task completion time

## 🔗 Key Resources

- **HyperFleet Architecture:** https://github.com/openshift-hyperfleet/architecture
- **Team Slack:** #hyperfleet-team, #hyperfleet-dev
- **Team Calendar:** [HyperFleet Team Events](link-to-calendar)
- **Documentation:** [Confluence Space](link-to-confluence)

## 🚨 Getting Help

**For Onboarding Issues:**
- Your assigned onboarding buddy (assigned on Day 1)
- Engineering manager
- Onboarding process owner: [Name/Slack handle]

**For Technical Issues:**
- Architecture office hours: Wednesdays 2pm ET
- #hyperfleet-dev Slack channel
- HyperFleet technical leads

## 📈 Continuous Improvement

This onboarding system evolves based on your feedback:
- **Day 3:** Quick pulse check
- **Day 10:** Mid-onboarding survey
- **Day 30:** Comprehensive feedback
- **Day 90:** Retrospective discussion

## 🔐 Security Note

This repository contains onboarding procedures but NO sensitive credentials. All cloud access, API keys, and production credentials are managed through secure systems (HashiCorp Vault, Red Hat SSO).

---

**Ready to get started?** Choose your role above and begin your HyperFleet journey! 🚀