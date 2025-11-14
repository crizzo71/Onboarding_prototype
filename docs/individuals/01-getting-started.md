# Getting Started - New Individual Contributor Guide

**Welcome to the HyperFleet team!** 🎉

This guide will walk you through your first week of onboarding and help you become a productive contributor within 2 weeks.

## 📋 Pre-Reading Checklist

Before diving into code, complete these foundational tasks:

- [ ] **Read this entire guide** (15 minutes)
- [ ] **Review the [PRD](../../README.md)** to understand project goals
- [ ] **Join essential Slack channels** (see Communication Setup below)
- [ ] **Meet with your onboarding buddy** (assigned by manager)

## 🎯 Week 1 Learning Objectives

By the end of Week 1, you should be able to:
- [ ] Explain HyperFleet's role in Red Hat's Hybrid Cloud Management strategy
- [ ] Identify the core components (API, Sentinel, Adapter, Broker) and their purposes
- [ ] Set up your local development environment
- [ ] Access staging environments and basic observability tools
- [ ] Navigate the codebase and architectural documentation

## 🏗️ What is HyperFleet?

**HyperFleet** is a cloud-agnostic cluster lifecycle management framework that enables Red Hat to manage Kubernetes clusters across multiple cloud providers (AWS, GCP, Azure) through a unified, event-driven architecture.

### Key Concepts You'll Work With

#### 1. **Event-Driven Architecture**
- Uses **CloudEvents 1.0** specification for standardized messaging
- Components communicate through message brokers (GCP Pub/Sub, RabbitMQ)
- Enables loose coupling and scalability across cloud providers

#### 2. **Core Components**
- **HyperFleet API**: REST endpoints for cluster management operations
- **HyperFleet Sentinel**: Kubernetes operator for orchestration decisions
- **HyperFleet Adapter**: Event-driven service for cloud-specific provisioning
- **HyperFleet Broker**: Message distribution abstraction layer
- **HyperFleet E2E**: Critical User Journey (CUJ) testing framework

#### 3. **Multi-Cloud Support**
- **AWS**: Integration with ROSA (Red Hat OpenShift on AWS)
- **GCP**: Native GKE integration with Google Cloud Platform
- **Azure**: Integration with ARO (Azure Red Hat OpenShift)

#### 4. **MVP Development Phase**
- Currently prioritizing speed over process while maintaining clear documentation
- All developers have write/merge access for rapid iteration
- 24-hour peer review window for changes
- Intentionally incurring technical debt with careful documentation

## 📱 Communication Setup

### Essential Slack Channels
Join these channels on your first day:

- **#hyperfleet-team** - General team discussions, announcements
- **#hyperfleet-dev** - Technical discussions, code reviews, development
- **#hyperfleet-incidents** - Production issues, on-call coordination
- **#hyperfleet-announcements** - Important team-wide updates

### Email Distribution Lists
Your manager will add you to:
- hyperfleet-team@redhat.com (all team members)
- hyperfleet-managers@redhat.com (if manager)

### Calendar Subscriptions
Ask your manager for invites to:
- Daily stand-ups
- Sprint ceremonies (planning, review, retro)
- Architecture office hours (Wednesdays 2pm ET)
- Team sync (bi-weekly)

## 👥 Your Onboarding Support Team

### Onboarding Buddy
- **Who:** Assigned peer from your sub-team (SWE/QE/SRE)
- **Role:** Daily technical questions, code review partner, cultural guide
- **Meeting Schedule:** Daily check-ins first week, then as needed

### Engineering Manager
- **Role:** Career guidance, administrative support, escalation point
- **Meeting Schedule:** Daily first 3 days, then weekly 1:1s

### Technical Leads/Architects
- **Role:** Architecture questions, design reviews, technical mentorship
- **Access:** Architecture office hours, ad-hoc technical discussions

## 📚 Required Reading - Week 1

### Day 1-2: Foundation
1. **[HyperFleet Architecture Summary](https://github.com/openshift-hyperfleet/architecture/blob/main/hyperfleet/architecture/architecture-summary.md)**
   - High-level system design
   - Component relationships
   - Event-driven patterns

2. **[Versioning Trade-offs](https://github.com/openshift-hyperfleet/architecture/blob/main/hyperfleet/docs/versioning-trade-offs.md)**
   - Current MVP approach
   - Future SDK strategy
   - Database migration patterns

### Day 3-4: Technical Deep-dive
3. **[Component Documentation](../architecture/component-deep-dives/)**
   - Read documentation for components you'll work on
   - Start with API layer, then Sentinel/Adapter based on role

4. **Kubernetes Operator Pattern Review** (if new to operators)
   - [Operator Pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
   - [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)

### Day 5: Integration Context
5. **[CLM Framework Relationship](../architecture/integration-guides/clm-integration.md)**
   - How HyperFleet fits into broader Red Hat strategy
   - Dependencies and integration points

## 🛠️ Next Steps

Once you've completed this guide:

1. **[Set up your development environment](02-environment-setup.md)**
2. **[Learn the architecture in detail](03-architecture-overview.md)**
3. **[Request cloud account access](04-cloud-accounts.md)**
4. **[Make your first contribution](05-first-contribution.md)**

## ❓ FAQ for New Team Members

**Q: How much time should I spend reading vs. coding in Week 1?**
A: Aim for 60% reading/learning, 40% hands-on environment setup. By Week 2, shift to 30% learning, 70% coding.

**Q: I'm overwhelmed by all the documentation. Where should I focus?**
A: Start with the Architecture Summary, then deep-dive into components relevant to your role. Your buddy can help prioritize.

**Q: When can I start contributing to production code?**
A: You can contribute to development/staging immediately. Production contributions typically start Week 3-4 after security training.

**Q: What if I don't have experience with Kubernetes operators?**
A: That's common! We have learning paths for different experience levels. Focus on the concepts first, then hands-on practice.

## 🆘 Getting Stuck?

**Immediate help:**
- Ask in #hyperfleet-dev Slack channel
- Reach out to your onboarding buddy
- Book time with your manager

**Technical architecture questions:**
- Architecture office hours: Wednesdays 2pm ET
- Tag @architects in #hyperfleet-dev

**Administrative issues:**
- Contact your manager
- Escalate to onboarding process owner: [Name/Slack]

---

**Next:** [Environment Setup Guide →](02-environment-setup.md)

*Estimated completion time: Day 1-2 of onboarding*