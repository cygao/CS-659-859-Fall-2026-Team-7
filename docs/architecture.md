# Architecture

The project has a local app, local persistence, and a replaceable resume tailoring service. The framework is not selected. Keep these boundaries when the team selects a platform.

## Components

| Component | Responsibility |
| --- | --- |
| Features | Collect user input and show application data and suggestions |
| Application repository | Save, load, update, and delete local records |
| Tailoring service | Return structured suggestions for a resume and a job |
| SQLite storage | Persist application, resume, suggestion, and tailored resume records |
| Local model adapter | Call an approved on-device model through the tailoring service |

The feature layer must not issue SQL or call a model directly. The repository must not format screens. The model adapter must not save accepted content.

## Service contracts

Use these behavior-level contracts in any implementation:

```text
ApplicationRepository
  listApplications() -> [JobApplication]
  saveApplication(JobApplication) -> JobApplication
  deleteApplication(id)
  loadMasterResume() -> Resume?
  saveMasterResume(Resume) -> Resume
  listSuggestions(applicationID) -> [ResumeSuggestion]
  saveSuggestion(ResumeSuggestion) -> ResumeSuggestion
  saveTailoredResume(TailoredResume) -> TailoredResume
  loadTailoredResumes(applicationID) -> [TailoredResume]

ResumeTailoringService
  suggest(resume: Resume, job: JobApplication) -> [ResumeSuggestion]
```

Use a deterministic mock tailoring service while the app UI and persistence work proceeds. The mock must return fixed, synthetic suggestions. It must not claim that a language model produced them.

Put the real local model behind the same tailoring service. The feature layer must work with either service. Do not add an external model service to the MVP.

## Persistence

Use SQLite with ordered schema migrations. For an approved schema change, add a new numbered migration after a migration has been shared. Never revise a migration after it is used. Store date-time values in UTC ISO 8601 form.

Enable SQLite foreign keys when a connection opens. A job delete must also remove its suggestions, tailored resumes, and accepted-suggestion links. A job delete must not remove the master resume.

Each suggestion and tailored resume stores the exact source resume text and its update time. These source fields cannot change after record creation. The snapshots keep the source clear when the user edits the master resume later. SQLite links each accepted suggestion to a tailored resume through a join table. Composite foreign keys require the same job and source revision. A trigger requires matching source text and an accepted decision.

An interchange importer must check that each accepted suggestion ID exists, has decision `Accepted`, and belongs to the same job as the tailored resume.

`migrations/001_initial.sql` defines the first schema. `schemas/application-data.schema.json` defines the JSON interchange contract. Keep both aligned with `docs/application-model.md`.

## Local data and privacy

Keep user data on the user's computer. Do not log resume or job description text. Use synthetic data in tests, screenshots, and demos. Do not add cloud sync, accounts, or remote storage without a new team decision.

## Open implementation choices

- App framework and minimum operating system
- SQLite library or platform API
- Local model provider and hardware requirements
- How the app imports the master resume
- Whether tailored text later gains file export
- Meaning and required fields for `Closed`
