-- Initial local SQLite schema. Do not change this migration after it is used.
PRAGMA foreign_keys = ON;

CREATE TABLE job_applications (
    id TEXT PRIMARY KEY NOT NULL,
    company TEXT NOT NULL CHECK (length(trim(company)) > 0),
    title TEXT NOT NULL CHECK (length(trim(title)) > 0),
    description TEXT NOT NULL CHECK (length(trim(description)) > 0),
    job_url TEXT,
    status TEXT NOT NULL CHECK (status IN ('Interested', 'Applied', 'Interviewing', 'Offer', 'Closed')),
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE TABLE master_resumes (
    id TEXT PRIMARY KEY NOT NULL,
    singleton_key INTEGER NOT NULL UNIQUE DEFAULT 1 CHECK (singleton_key = 1),
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    content TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE TABLE resume_suggestions (
    id TEXT PRIMARY KEY NOT NULL,
    application_id TEXT NOT NULL REFERENCES job_applications(id) ON DELETE CASCADE,
    source_resume_id TEXT NOT NULL REFERENCES master_resumes(id) ON DELETE RESTRICT,
    source_resume_content TEXT NOT NULL,
    source_resume_updated_at TEXT NOT NULL,
    source_text TEXT NOT NULL CHECK (length(trim(source_text)) > 0),
    proposed_text TEXT NOT NULL CHECK (length(trim(proposed_text)) > 0),
    rationale TEXT NOT NULL CHECK (length(trim(rationale)) > 0),
    decision TEXT NOT NULL CHECK (decision IN ('Pending', 'Accepted', 'Rejected')),
    UNIQUE (id, application_id, source_resume_id, source_resume_updated_at)
);

CREATE TABLE tailored_resumes (
    id TEXT PRIMARY KEY NOT NULL,
    application_id TEXT NOT NULL REFERENCES job_applications(id) ON DELETE CASCADE,
    source_resume_id TEXT NOT NULL REFERENCES master_resumes(id) ON DELETE RESTRICT,
    source_resume_content TEXT NOT NULL,
    source_resume_updated_at TEXT NOT NULL,
    content TEXT NOT NULL,
    saved_at TEXT NOT NULL,
    UNIQUE (id, application_id, source_resume_id, source_resume_updated_at)
);

CREATE TABLE tailored_resume_suggestions (
    tailored_resume_id TEXT NOT NULL,
    application_id TEXT NOT NULL,
    source_resume_id TEXT NOT NULL,
    source_resume_updated_at TEXT NOT NULL,
    suggestion_id TEXT NOT NULL,
    PRIMARY KEY (tailored_resume_id, suggestion_id),
    FOREIGN KEY (tailored_resume_id, application_id, source_resume_id, source_resume_updated_at)
        REFERENCES tailored_resumes(id, application_id, source_resume_id, source_resume_updated_at) ON DELETE CASCADE,
    FOREIGN KEY (suggestion_id, application_id, source_resume_id, source_resume_updated_at)
        REFERENCES resume_suggestions(id, application_id, source_resume_id, source_resume_updated_at) ON DELETE CASCADE
);

CREATE TRIGGER tailored_resume_suggestion_must_be_accepted
BEFORE INSERT ON tailored_resume_suggestions
FOR EACH ROW
WHEN NOT EXISTS (
    SELECT 1
    FROM tailored_resumes AS tailored
    JOIN resume_suggestions AS suggestion
      ON suggestion.id = NEW.suggestion_id
     AND suggestion.application_id = NEW.application_id
    WHERE tailored.id = NEW.tailored_resume_id
      AND tailored.application_id = NEW.application_id
      AND tailored.source_resume_id = NEW.source_resume_id
      AND tailored.source_resume_updated_at = NEW.source_resume_updated_at
      AND suggestion.source_resume_id = NEW.source_resume_id
      AND suggestion.source_resume_updated_at = NEW.source_resume_updated_at
      AND suggestion.source_resume_content = tailored.source_resume_content
      AND suggestion.decision = 'Accepted'
)
BEGIN
    SELECT RAISE(ABORT, 'only accepted suggestions can be linked');
END;

CREATE TRIGGER tailored_resume_suggestion_update_must_be_accepted
BEFORE UPDATE ON tailored_resume_suggestions
FOR EACH ROW
WHEN NOT EXISTS (
    SELECT 1
    FROM tailored_resumes AS tailored
    JOIN resume_suggestions AS suggestion
      ON suggestion.id = NEW.suggestion_id
     AND suggestion.application_id = NEW.application_id
    WHERE tailored.id = NEW.tailored_resume_id
      AND tailored.application_id = NEW.application_id
      AND tailored.source_resume_id = NEW.source_resume_id
      AND tailored.source_resume_updated_at = NEW.source_resume_updated_at
      AND suggestion.source_resume_id = NEW.source_resume_id
      AND suggestion.source_resume_updated_at = NEW.source_resume_updated_at
      AND suggestion.source_resume_content = tailored.source_resume_content
      AND suggestion.decision = 'Accepted'
)
BEGIN
    SELECT RAISE(ABORT, 'only accepted suggestions can be linked');
END;

CREATE TRIGGER suggestion_source_snapshot_is_immutable
BEFORE UPDATE OF source_resume_id, source_resume_content, source_resume_updated_at
ON resume_suggestions
FOR EACH ROW
WHEN NEW.source_resume_id != OLD.source_resume_id
  OR NEW.source_resume_content != OLD.source_resume_content
  OR NEW.source_resume_updated_at != OLD.source_resume_updated_at
BEGIN
    SELECT RAISE(ABORT, 'suggestion source snapshot is immutable');
END;

CREATE TRIGGER tailored_resume_source_snapshot_is_immutable
BEFORE UPDATE OF source_resume_id, source_resume_content, source_resume_updated_at
ON tailored_resumes
FOR EACH ROW
WHEN NEW.source_resume_id != OLD.source_resume_id
  OR NEW.source_resume_content != OLD.source_resume_content
  OR NEW.source_resume_updated_at != OLD.source_resume_updated_at
BEGIN
    SELECT RAISE(ABORT, 'tailored resume source snapshot is immutable');
END;

CREATE TRIGGER linked_suggestion_must_remain_accepted
BEFORE UPDATE OF decision ON resume_suggestions
FOR EACH ROW
WHEN NEW.decision != 'Accepted'
 AND EXISTS (
     SELECT 1 FROM tailored_resume_suggestions
     WHERE suggestion_id = OLD.id AND application_id = OLD.application_id
 )
BEGIN
    SELECT RAISE(ABORT, 'linked suggestions must remain accepted');
END;

CREATE INDEX resume_suggestions_by_application
    ON resume_suggestions(application_id);

CREATE INDEX tailored_resumes_by_application
    ON tailored_resumes(application_id, saved_at);

CREATE INDEX tailored_resume_suggestions_by_suggestion
    ON tailored_resume_suggestions(suggestion_id);

PRAGMA user_version = 1;
