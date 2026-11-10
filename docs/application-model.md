# Application Model

This document defines the shared data contract. The contract is independent of the app framework. It supports the board, job editor, and resume customizer.

## Records

### JobApplication

One record represents a saved job and its later application stages. The board and job editor use the same record.

| Field | Type | Rule |
| --- | --- | --- |
| `id` | UUID string | Required and stable for the record's life |
| `company` | string | Required |
| `title` | string | Required |
| `description` | string | Required; may be empty before validation in an edit form, but not in a saved record |
| `jobURL` | URL string or null | Optional |
| `status` | enum | `Interested`, `Applied`, `Interviewing`, `Offer`, or `Closed` |
| `notes` | string or null | Optional |
| `createdAt` | date-time string | Required |
| `updatedAt` | date-time string | Required |

The team has not defined what `Closed` means. Do not infer a reason from this status. Do not add a close reason field until the team defines it.

### Resume

`Resume` is the user's master resume. The first release supports one master resume. It has an `id`, `name`, `content`, and `updatedAt` value. The interchange field `masterResume` is null when the user has not added a resume. Keep its content unchanged when you create a tailored version.

### ResumeSuggestion

A suggestion belongs to one job and one source resume. It has an `id`, `applicationID`, `sourceResumeID`, `sourceResumeContent`, `sourceResumeUpdatedAt`, `sourceText`, `proposedText`, `rationale`, and `decision` value. The decision is `Pending`, `Accepted`, or `Rejected`.

Store the exact master resume text and update time that the tailoring service used. These source fields are immutable after creation. This keeps the source clear if the user edits the master resume while a suggestion is pending or after the user accepts it.

Show the source text, proposed text, and rationale together. A user must decide on each suggestion. Do not silently include pending suggestions in a saved version.

### TailoredResume

A tailored resume belongs to one job and records the source master resume. It has an `id`, `applicationID`, `sourceResumeID`, `sourceResumeContent`, `sourceResumeUpdatedAt`, `content`, `acceptedSuggestionIDs`, and `savedAt` value. Store the exact source text and timestamp used to create it. These source fields are immutable after creation. This preserves the source even if the user later edits the master resume. Saving it must not change the master resume.

The first contract stores tailored content as text. File export is out of scope unless the team changes the project plan.

## Interchange

Use `schemas/application-data.schema.json` to validate an interchange document. The document contains one version number, a master resume or null, job applications, suggestions, and tailored resumes. Dates use RFC 3339 date-time strings. IDs use UUID strings.

The JSON schema checks each record's shape. An importer must also check every `acceptedSuggestionIDs` entry. The suggestion must exist, its decision must be `Accepted`, and its `applicationID` must match the tailored resume's `applicationID`. Its `sourceResumeID`, `sourceResumeContent`, and `sourceResumeUpdatedAt` must also match the tailored resume's source fields.

See `examples/sample-project.json` for synthetic data. Do not put real names, resumes, or job contact details in the sample.

## Contract rules

1. Keep one job application ID as the record moves between statuses.
2. Keep suggestions separate from master resume text.
3. Save only user-accepted changes to a tailored resume.
4. Preserve the exact source resume text and update time for every suggestion and tailored version.
5. Do not create a claim that the source resume does not support.
6. Keep names, fields, and status labels consistent across features.
