# ADR-0001: App Platform

- **Status:** Open; provisional recommendation only
- **Date:** 2026-11-09
- **Decision owner:** Team

## Context

The approved proposal calls for a local, Apple-powered job application and resume tool. The team has not confirmed the app framework, member hardware, or local model support. This ADR records options and the checks required before a final choice.

## Options

| Option | Benefits | Costs and risks |
| --- | --- | --- |
| SwiftUI, SwiftData, and Apple Foundation Models | Direct access to Apple platform features; few runtime parts | Requires suitable Macs and shared Swift skills; local model support depends on each device and OS |
| Tauri, React, SQLite, and Ollama | Familiar web UI; local model choice is flexible | Adds Rust and local service setup; more parts to install and support |
| Tauri, React, and Apple Foundation Models | Web UI with Apple's model | Requires a custom native bridge and adds integration work |

## Provisional direction

SwiftUI with a local persistence layer and an injected tailoring service is the provisional first choice. It fits the local Mac goal and limits infrastructure. The team has not locked this choice. SwiftData is also not selected; the shared persistence contract uses SQLite migrations so the team can compare a platform API with a direct SQLite library.

## Validation before lock

1. Ask each member to clone the repository and build a small Swift package.
2. Record each member's Mac, macOS, and Xcode availability.
3. On a supported machine, make a small app call the on-device Foundation Models API and return structured output.
4. Save, load, and update one record in SQLite from the same prototype.
5. Compare the time and setup burden with a Tauri and Ollama spike.
6. Record the team decision and update `project.md` and this ADR.

Do not start app UI work until the team selects one visual direction from the approved mockups. A platform decision does not approve a visual direction.

## Consequences

The current repository stays framework-neutral. It defines shared records, a SQLite schema, JSON interchange, and service boundaries. The team can change the app framework without changing these contracts by default.
