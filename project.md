# Team Project Plan

## Motivation

Job seekers must track many applications and tailor resumes for each role. This work can take time and expose personal information to online services.

The team proposes a local app that helps one job seeker manage applications and prepare role-specific resumes. The app must keep the job seeker in control of every resume change.

## Goal

Support one complete workflow: save a job, track its progress, tailor resume content to that job, review each change, and keep the work on the user's computer.

The main demo should take 3–5 minutes. It should start with a master resume and end with a saved, reviewed version for one job.

## Target Users And Main Workflow

- **Primary user:** A job seeker who manages several applications and wants to tailor a resume for each role.
- **Primary workflow:** Add a job, find it on the board, open its resume customizer, review suggestions, save accepted changes, and mark the job as applied.
- **Design target:** A local Mac desktop app. This is a working assumption until the team confirms its platform and technology stack.

## Scope

### In scope

- A Kanban board for saved and active job applications.
- A job form to add and edit a job record.
- A resume customizer for one selected job and one master resume.
- Suggestions that show the source text, proposed text, and a reason.
- Clear user actions to accept or reject each suggestion.
- Local storage and clear loading, empty, success, and error states.

### Out of scope

- Submitting job applications for the user.
- Scraping job sites or importing jobs from URLs automatically.
- Accounts, cloud sync, and shared editing.
- An ATS score or a claim that the app can predict hiring results.
- PDF import and export unless the team has time after the MVP works.

## Shared Product Rules

1. The master resume stays unchanged when the app creates a tailored version.
2. The app must not add skills, experience, or results that are absent from the source resume.
3. The user must review and accept each proposed change before the app saves it.
4. A saved job and an application use one shared record. Its status shows its current stage.
5. Screens must use the same job title, company, and status wherever they show the same record.
6. Use synthetic names and resume details in mockups and project demos.

## Screen Requirements

### 1. Job Applications Kanban

**User goal:** See the current job search at a glance and move a job to its next stage.

**The screen must show:**

- A clear page title and a primary **Add job** action.
- Columns for **Interested**, **Applied**, **Interviewing**, **Offer**, and **Closed**.
- Job cards with company, role, current status, and the next useful date when one exists.
- A clear way to open a job and its resume customizer.
- Search or simple filters when the board has many jobs.

**The user must be able to:**

- Move a job to another stage with a clear action.
- Open a job to view or edit its details.
- Start a tailored resume for that job.
- Find the add-job form from the board.

**States to include in mockups:** A board with jobs, an empty board, and a board with no search results. Show a clear next action in each empty state.

**Mockup acceptance:** A viewer can identify each job's stage and find the next action without opening every card. The add-job and resume-customizer paths are visible.

### 2. Resume Customizer

**User goal:** Improve how the resume presents relevant experience for one job, while keeping every claim grounded in the master resume.

**The screen must show:**

- The selected company and role, with a way to return to the job record.
- The resume source used for this version.
- The job description or selected job requirements used for suggestions.
- Original resume text beside each proposed revision.
- A short reason for each suggestion.
- Separate **Accept** and **Reject** actions for each suggestion.
- A clear action to save the accepted changes as a job-specific version.

**The user must be able to:**

- Review suggestions one at a time.
- Accept or reject a suggestion without changing the master resume.
- See which suggestions remain undecided.
- Save the reviewed version for the selected job.

**States to include in mockups:** No master resume, no job description, suggestions loading, suggestions ready, generation failed, and all suggestions reviewed. Each state must explain what happened and offer a useful next action.

**Mockup acceptance:** A viewer can tell what changed, why it changed, and which action will save it. The master resume is clearly separate from the tailored version.

### 3. Add And Edit Jobs

**User goal:** Save a job with enough detail to track it and request relevant resume suggestions.

**The screen must show:**

- Fields for company, role title, job description, and optional job URL.
- An initial status of **Interested** for a new record.
- A save action and a clear way to cancel or return to the board.
- Validation next to any missing required field.
- For an existing job, the current details and status, plus a save action.
- A distinct **Mark as applied** action. This records the user's action; it does not submit an application.

**The user must be able to:**

- Add a job and see it appear on the board.
- Edit a saved job without creating a duplicate.
- Save without a URL.
- Correct invalid or missing required fields.
- Mark the job as applied after submitting it outside the app.

**States to include in mockups:** Blank form, form with valid details, validation error, save in progress, save success, and edit mode. Make add and edit modes easy to distinguish.

**Mockup acceptance:** A viewer can tell which fields are required, how to save or cancel, and how to record that they applied. The interface does not imply that the app submits applications.

## Constraints And Open Questions

- The application and its data should remain on the user's computer for the MVP.
- The team has not confirmed the app framework or local model. Do not present a framework as a settled choice.
- Local model limits may affect how much resume and job text the app can process at once.
- The app must handle missing input and model failures without losing user edits.
- UI implementation belongs to the assigned feature owners. Shared setup work must not create screens or choose a visual direction for them.
- The team must confirm whether **Closed** means rejected, withdrawn, or both.
- The team must confirm whether a tailored version is saved as text, a file, or both.
- The team must confirm the intended screen size and minimum supported Mac setup before detailed mockups.

## Decisions And Validation

| Decision | Reason | Validation |
| --- | --- | --- |
| Use one job-application record for a saved job and its later application stages. | This keeps the board and job form on one shared record. | Add a job, change its status, edit it, and confirm the same card updates. |
| Keep resume suggestions separate from the master resume. | This protects the source and makes each change reviewable. | Accept and reject suggestions, then confirm the master resume is unchanged. |
| Treat **Mark as applied** as tracking only. | The project does not include automatic application submission. | Review the form and board labels with a teammate who did not design them. |
| Assume a local Mac desktop app for early requirements. | The proposal describes a local, Apple-powered app, but the stack is not settled. | Confirm the target platform and team setup before producing detailed visual mockups. |
| Keep the shared data contract and SQLite schema independent of the UI framework. | This gives all feature owners one data shape while the team tests its platform choices. | Apply the schema to a new local database and validate the sample data. Then confirm the framework and model adapter with a team build and local-inference spike. |

## Team Ownership

- **Ethan:** Kanban board and application stages.
- **Biniam:** Resume customizer and suggestion review.
- **Abraham:** Add and edit job records.
- **Cameron:** Shared data, local storage, model integration, and project integration.

Each owner should coordinate the shared job fields and status names before implementation. Feature owners should also review the complete workflow with the team.

## Acceptance Criteria For The MVP

1. A user can add a job with a company, title, and description.
2. The new job appears in the **Interested** column.
3. A user can edit the same job and move it to another stage.
4. A user can view resume suggestions for a selected job.
5. Each suggestion shows its source text, proposed text, and reason.
6. A user can accept or reject suggestions and save a job-specific version.
7. The master resume remains unchanged after the user saves a tailored version.
8. The job and resume data remain available after the user closes and reopens the app.
9. The main workflow can be demonstrated in 3–5 minutes with synthetic data.
10. Missing input and model errors show a recovery action and do not discard unsaved user edits.

## Current Status And Next Step

**Status:** Product requirements and the stack-neutral data and agent-workflow foundation are in place. Six screen mockups are saved under `mockups/`. No frontend screens or runnable app have been created. The app stack remains open.

**Mockups:** `applications-board-a.png` and `applications-board-b.png` show the Kanban view. `resume-customizer-a.png` and `resume-customizer-b.png` show resume review. `job-form-a.png` shows add mode, and `job-form-b.png` shows edit mode.

**Next step:** Review the requirements, data contract, schema, and mockups with the team. Validate the SQLite migration and sample data. Confirm the platform and storage/model adapter after the build spike. Feature owners implement their own screens against the shared data contract.
