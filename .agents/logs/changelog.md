# Changelog

Dated record of every meaningful change to {{PROJECT_NAME}}. Updated after every completed task.

## Format

Each entry uses this template:

```md
## YYYY-MM-DD

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Refactored
- ...

### Performance
- ...

### Tests
- ...

### Docs
- ...

### Tooling
- ...

### Known Issues
- ...
```

Omit any subsection that has no entries for that date. Every completed task must produce at least one changelog entry.

---

<!-- FILL: Append new dated entries below in reverse-chronological order (newest first). -->

## 2026-06-03

### Added
- Initial Agent Harness OS template: `AGENTS.md`, `CLAUDE.md`, `init.sh`, `feature_list.json`, state files, `evaluator-rubric.md`, `clean-state-checklist.md`.
- `.agents/` harness: 12 context docs, 17 workflows (incl. `adoption.md`), 9 log scaffolds, proposals + artifacts indexes.
- `.github/` issue forms (epic / sub-issue / bug / feature) + PR template.
- Root `README.md` landing page with CI badge.
- `scripts/verify-harness.sh` — single source of verification truth.
- `.github/workflows/ci.yml` — self-verifying CI on push/PR to `main`.
- `.gitignore` protecting secrets and env files.

### Tooling
- CI runs `verify-harness.sh` (structure, length limits, JSON/YAML, link resolution, no-attribution, no-secrets, shell syntax); 11/11 checks pass locally.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
