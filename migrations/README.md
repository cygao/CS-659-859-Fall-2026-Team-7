# SQLite Migrations

Migration files define the local database schema. Apply them in number order. When a migration has been used, never revise it. Add a new numbered file for each approved schema change.

`001_initial.sql` creates the first schema. It sets SQLite `user_version` to `1`. Enable foreign keys on every database connection.

Keep migration changes aligned with `schemas/application-data.schema.json` and `docs/application-model.md`.
