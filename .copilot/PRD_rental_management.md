Follow the PRD_instructions.md methodology and template.

**Version:** 0.5  
**Last Updated:** 2025-12-03  
**Author:** Jean-Philippe  
**Status:** Draft

#### Revision History

| Version | Date       | Author        | Changes                                           |
| ------- | ---------- | ------------- | ------------------------------------------------- |
| 0.1     | 2025-12-03 | Jean-Philippe | Initial skeleton draft for Rental Management Tool |
| 0.2     | 2025-12-03 | Jean-Philippe | Draft Executive Summary added                     |
| 0.3     | 2025-12-03 | Jean-Philippe | Draft Functional Requirements added               |
| 0.4     | 2025-12-03 | Jean-Philippe | Draft Vacation Rentals compatibility added        |
| 0.5     | 2025-12-03 | Jean-Philippe | Prioritize vacation rentals as primary product focus |

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

- Core features:

  - Property & unit management: create/edit properties, units, unit types, add photos and documents, set rent, security deposit, and available dates.
  - Tenant profiles and onboarding: capture contact details, documents (ID, proof of income), assign to units, record lease start/end and rent terms.
  - Lease management: create, upload, and sign digital lease agreements; store lease terms, renewal rules, and notice periods.
  - Rent invoicing & payments: generate recurring invoices, support online payments via integrated payment provider, record offline payments, handle partial payments and apply late fees.
  - Maintenance & tickets: tenants or managers submit maintenance requests, technicians assigned, status tracking, messaging and attachments, cost logging.
  - Notifications & reminders: automated rent reminders, overdue notices, maintenance updates via email/SMS (configurable).
  - Reporting & exports: rent roll, payments ledger, arrears report, export CSV/PDF for accounting.

- Edge cases & special flows:

  - Partial payments and automatic allocation across invoices.
  - Prorated rent on move-in / move-out.
  - Late fee calculation with configurable grace periods.
  - Security deposit handling and refund workflows.
  - Lease transfer, subletting flags and approvals.
  - Multi-currency display (MVP: display only; payments single-currency depending on provider).

- Non-functional requirements (high level):

  - Performance: page loads < 500ms for primary dashboard actions under typical load.
  - Scalability: support portfolios up to 5,000 units in a single tenant account; design to scale horizontally.
  - Security: encrypted data at rest and in transit, role-based access control, audit logs for financial actions.
  - Availability & Backup: 99.9% uptime target, daily backups with point-in-time recovery for 30 days.

- Acceptance criteria (per feature):
  - Property management: create/edit/delete a property and at least one unit; changes persist and visible to other managers.
  - Tenant onboarding: create tenant profile, attach required documents, assign tenant to a unit and create a lease record.
  - Rent payments: generate invoice, accept a payment (online or offline), reflect in payments ledger, and update tenant balance.
  - Maintenance: submit a ticket with attachment, change status through lifecycle, and record resolution notes and costs.
  - Reporting: export rent roll and payments ledger within 30 seconds for up to 5,000 units.

### Vacation Rentals Compatibility

This product's core feature set is compatible with short-term / vacation rentals in many ways, but supporting vacation-rental workflows requires additional entities, flows and integrations. The sections below describe gaps, recommended minimal MVP changes, acceptance criteria for short-term rentals, and data-model notes.

- Compatibility summary:

  - Works well: property/unit management, guest/tenant contact profiles, payment recording, maintenance/ticketing, basic reporting and exports.
  - Missing or partial: booking/reservation lifecycle, calendar and availability sync, per-night rate models, cleaning/turnover ops, tourism taxes and compliance, channel integrations.

- Identified gaps (needed for vacation-rental parity):

  - Reservation & Booking: dedicated reservation entity and lifecycle separate from long-term leases (requested → confirmed → checked-in → checked-out → closed).
  - Availability Calendar & Blocking: per-unit calendar view, manual blocks, and iCal import/export for channel sync.
  - Pricing & Fees: nightly rates, seasonal/weekday/weekday rules, cleaning fees, extra-guest fees, minimum-night rules, discounts/coupons.
  - Security Deposits & Damage Handling: pre-authorizations, hold capture, damage claims and settlement flow.
  - Turnover & Operations: cleaning tasks generation, scheduling, and assignment on checkout.
  - Channel Manager Integrations: at least iCal import/export; bi-directional marketplace sync is optional for later phases.
  - Tax & Compliance: transient occupancy / tourist tax calculation and reporting (collection/remittance out-of-scope for MVP).
  - Guest Messaging & Check-in: guest-facing templates and automated messages, check-in instructions, and self-checkin flows.

- Minimal MVP-friendly additions to support vacation rentals:

  - Add `Reservation` entity and simple calendar UI with iCal import/export.
  - Support per-night pricing with a basic `RatePlan` (base nightly + cleaning + min nights).
  - Add security deposit hold recording and a refund/settlement flow.
  - Auto-generate a cleaning/turnover task on checkout.
  - Provide guest messaging templates (confirmation, check-in, checkout reminders).

- Acceptance criteria (vacation-rental scenarios):

  - Create Reservation: create a reservation for a unit, block the calendar for the reservation dates, and set status to `confirmed`.
  - Reservation Invoicing: generate an invoice for a reservation (nightly rate, cleaning fee, taxes) and record payment.
  - Security deposit: record a deposit hold and later release or apply to damages with audit trail.
  - Turnover task: checkout triggers a cleaning task assigned to a team/worker and visible in the operations list.
  - Calendar sync: import an iCal feed and block conflicting dates on the internal calendar.

- Data model / integration notes:
  - New entities: `Reservation`, `RatePlan`, `CalendarAvailability`, `CleaningTask`, `DepositHold`, `GuestMessageTemplate`.
  - Integrations: iCal (low-effort), payment provider for deposits (Stripe/Adyen), optional ID-check providers.
  - Compliance: flag units subject to transient-occupancy taxes and store relevant permit/registration data in unit metadata.

These changes are backward compatible with long-term rental workflows: a `Reservation` is separate from a `Lease` and uses the same unit records.

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
