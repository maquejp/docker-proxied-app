Follow the PRD_instructions.md methodology and template.

**Version:** 0.2  
**Last Updated:** 2025-12-03  
**Author:** Jean-Philippe  
**Status:** Draft

#### Revision History

| Version | Date       | Author        | Changes                                           |
| ------- | ---------- | ------------- | ------------------------------------------------- |
| 0.1     | 2025-12-03 | Jean-Philippe | Initial skeleton draft for Rental Management Tool |
| 0.2     | 2025-12-03 | Jean-Philippe | Draft Executive Summary added                     |

### 1. Executive Summary

- Purpose: Build a lightweight, practical rental management tool for small-to-medium landlords and property managers. The product centralizes property and tenant data, simplifies rent collection, streamlines maintenance workflows, and provides essential financial and operational reports. It targets owners who currently manage properties with spreadsheets, email, and phone workflows and need a reliable, low-friction digital alternative.

- Scope (MVP):

  - In-scope: property and unit management, tenant profiles, digital lease records, rent invoicing and online payments (via payment-provider integration), maintenance request / ticketing, role-based access (owner, manager, tenant, maintenance), basic reporting (rent roll, arrears, payments), and secure data export.
  - Out-of-scope for MVP: full double-entry accounting, eviction/legal workflows, advanced tax reporting, multi-language localization, and large-enterprise portfolio features.

- Alignment with goals: Reduce time-to-collect rent, lower manual administrative effort (target >40% reduction vs spreadsheets), improve tenant satisfaction through clearer payment and maintenance flows, and provide landlords with auditable records for financial and regulatory needs.

- Metrics to track success for MVP:
  - Adoption: number of landlords and properties onboarded in first 3 months.
  - Financial: percentage of rent collected on-time, average days-to-collect.
  - Operational: reduction in manual admin time (self-reported) and ticket resolution time.
  - Satisfaction: NPS or customer satisfaction score after onboarding.

### 2. Stakeholders & Personas

- Primary users: e.g., property managers, landlords.
- Secondary users: tenants, maintenance staff, accountants.
- Stakeholder expectations: reporting, compliance, reliability.

### 3. Objectives & Success Criteria

- Business objectives: revenue, retention, operational efficiency.
- Technical objectives: uptime, response times, data integrity.
- Measurable success metrics: adoption, time-to-collect rent, NPS.

### 4. Functional Requirements

- Core features: property and unit management, tenant onboarding, rent collection, maintenance requests, lease management.
- Edge cases: partial payments, late fees, evictions, multi-currency, subletting.
- Non-functional requirements: performance, scalability, security, backup/restore.

### 5. System Architecture Considerations

- Platforms & frameworks: web, mobile, integrations (payment gateways, accounting).
- Constraints: GDPR, PCI DSS (if payments), portability, hosting limits.
- Risks & mitigations: payment failures, data breaches, regulatory changes.

### 6. User Experience & Design

- User flows: onboarding, rent payment flow, maintenance ticket lifecycle.
- Wireframe notes: dashboard, property card, tenant profile.
- Accessibility: keyboard navigation, WCAG conformance targets.

### 7. Roadmap & Milestones

- Phases: prototype → MVP → GA release.
- Dependencies: payment provider, accounting integration, legal review.
- Timeline: high-level milestones and target dates.

### 8. Validation & Acceptance

- Test scenarios: end-to-end payments, lease creation, data migration.
- Acceptance criteria: pass/fail criteria per feature.
- Review process: stakeholders, QA, legal acceptance steps.

---

Notes:

- This is an initial skeleton. Specify which section to expand next.
