# Agent Guide

## Product contract

Read `project.md` before you change product behavior. Treat it as the current product contract. The framework and visual direction remain open until the team records a decision.

Keep the app local. Do not add accounts, cloud sync, job-site scraping, automatic job submission, or ATS scores. Use synthetic data in examples and demos.

The master resume is source data. Never change it when you create a tailored resume. A user must review and accept each suggestion before the app saves the tailored content. Do not add facts that the source resume does not support.

## Shared model

Use one `JobApplication` record from job entry through later stages. Use the status names `Interested`, `Applied`, `Interviewing`, `Offer`, and `Closed` across all features. The meaning of `Closed` is unresolved. Do not infer a reason from that status.

Read `docs/application-model.md` before you change a shared field, status, or service boundary. Update the JSON schema, sample data, and docs together when the team approves a contract change. If a shared migration has been used, add a new numbered migration. Never revise a migration after use.

## Team ownership

- Ethan owns the Kanban board and application stages.
- Biniam owns resume customization and suggestion review.
- Abraham owns adding and editing job records.
- Cameron owns shared data, local storage, model integration, and project integration.

Each owner builds a vertical feature. Coordinate shared fields before you change them. Keep persistence and model inference behind services so feature work can use deterministic mock data.

## Work with coding agents

Give an agent one bounded task with files and acceptance criteria. Read its changes. Run the relevant checks and demonstrate the behavior before you accept the work. The human owner remains responsible for each change.

Do not change a shared contract as an incidental part of a feature. Propose the change and record the decision first. Do not add a package, external service, or framework before the team approves it.

Before you build interactive screens, use the approved visual direction in `mockups/`. Do not create or change visual targets without team agreement.

## Documentation

Write technical documentation in clear, direct English. Keep `project.md` current with scope, constraints, decisions, acceptance criteria, and status. Record unresolved choices as open; do not present assumptions as decisions.
