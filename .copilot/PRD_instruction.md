# PRD Drafting Instructions for Copilot

## Purpose

This file defines the strict methodology to be followed when generating or refining a Product Requirements Document (PRD) for personal or professional projects.

## Workflow

1. **Skeleton Generation (GPT‑5‑mini)**

   - Generate a PRD outline using the template below.
   - Keep sections concise, only headings and bullet placeholders.

2. **Detailed Drafting (GPT‑4.1)**

   - Expand each section with structured reasoning.
   - Include technical constraints, risks, and architecture notes.
   - Ensure clarity and compliance with standard methodologies.

3. **Iterative Refinement (GPT‑4o)**

   - Brainstorm alternatives, edge cases, and UX flows.
   - Refine language for readability and accessibility.
   - Stress‑test requirements by asking for failure scenarios.

4. **Final Pass (GPT‑4.1)**
   - Ensure coherence, completeness, and formal tone.
   - Validate acceptance criteria and success metrics.

---

## Git Discipline

### Commit Convention

- Use **Conventional Commits** format:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation changes (including PRD updates)
  - `refactor:` for restructuring without changing behavior
  - `chore:` for maintenance tasks

Examples:

- docs(prd): add architecture considerations section
- feat(prd): define new user persona
- fix(prd): correct success metric wording

### Branching Strategy

- Always create a **branch per feature or PRD section**.
  - Examples: `feature/prd-user-stories`, `feature/prd-architecture`, `feature/prd-validation`
- Merge into `main` only after review and validation.
- Align PRD version numbers with branch merges (e.g., PRD v1.2 ↔ merge of `feature/prd-ux`).

---

## PRD Template

### Version Control

**Version:** X.Y  
**Last Updated:** YYYY‑MM‑DD  
**Author:** Jean‑Philippe  
**Status:** Draft / Approved / Archived

#### Revision History

| Version | Date       | Author        | Changes                               |
| ------- | ---------- | ------------- | ------------------------------------- |
| 0.1     | YYYY‑MM‑DD | Jean‑Philippe | Initial skeleton draft                |
| 0.9     | YYYY‑MM‑DD | Jean‑Philippe | Added functional requirements section |
| 1.0     | YYYY‑MM‑DD | Jean‑Philippe | Finalized architecture considerations |

### 1. Executive Summary

- Purpose
- Scope
- Alignment with goals

### 2. Stakeholders & Personas

- Primary users
- Secondary users
- Stakeholder expectations

### 3. Objectives & Success Criteria

- Business objectives
- Technical objectives
- Measurable success metrics

### 4. Functional Requirements

- Core features
- Edge cases
- Non‑functional requirements (performance, scalability, compliance)

### 5. System Architecture Considerations

- Platforms, frameworks, integrations
- Constraints (GDPR, portability, resource limits)
- Risks and mitigations

### 6. User Experience & Design

- User flows
- Wireframe notes
- Accessibility considerations

### 7. Roadmap & Milestones

- Phases (prototype → MVP → release)
- Dependencies
- Timeline

### 8. Validation & Acceptance

- Test scenarios
- Acceptance criteria
- Review process

---

## Prompting Guidelines

- Always start with: _“Follow the PRD_instructions.md methodology and template.”_
- Copilot must **auto‑increment the version number** and **append a new entry in the Revision History** whenever changes are made.
- Use slot‑filling: ask Copilot to complete one section at a time.
- Iterate until each section is fully detailed.
