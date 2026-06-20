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

## 2026-06-20

### Added
- **Invokable slash commands** — `.claude/commands/` (24): orchestration/issues (`/gated-orchestration`, `/issue-plan`, `/issue-breakdown`, `/issue-handoff`), context (`/context-map`, `/refresh-context`), authoring (`/create-skill`, `/create-command`), loops (`/build-loop`, `/goal`, `/autonomous-loop`, `/review-loop`, `/fix-loop`, `/test-loop`, `/docs-loop`, `/issue-loop`, `/skill-evolution-loop`), review/safety (`/review-pr`, `/review-10x`, `/security-review`, `/architecture-review`), delivery (`/ci-debug`, `/release-check`, `/final-handoff`).
- **Project skills** — `.claude/skills/` (12): `repo-discovery`, `github-issue-planning`, `context-mapping`, `command-authoring`, `skill-authoring`, `autonomous-loop-design`, `opus-code-review`, `security-review`, `test-debugging`, `documentation-maintenance`, `handoff-writing`, `release-readiness`.
- **Reusable, model-tiered subagents** — `.claude/agents/` (11): `planner`/`architect`/`reviewer`/`safety-reviewer`/`integrator`/`skill-smith` (opus), `implementer`/`tester`/`debugger`/`docs-writer` (sonnet), `scout` (haiku, read-only) — for dynamic-workflow parallelism.
- **Autonomous loop system** — `.agents/workflows/autonomous-loops.md` (loop schema, bounded iteration caps, stop/escalation/handoff/recovery).
- **Recursive context maps** — local `AGENTS.md` in `.github/`, `scripts/`, `.agents/`, `.agents/logs/`, `.claude/skills/`; `.claude/README.md`; `.agents/workflows/context-mapping.md`.
- **New context docs** — `.agents/context/slash-commands.md`, `.agents/context/subagents.md`, `.agents/context/failure-modes.md`.
- Root `CONTRIBUTING.md`.

### Changed
- Reconciled the spec onto the existing `.agents/` structure (no parallel `docs/` tree).
- `.agents/workflows/review.md` — added the six review gates. `github-issues.md` — extended label taxonomy (`type: command`, `type: agent-skill`, `area: *`).
- Root `AGENTS.md` / `CLAUDE.md` / `README.md` / `.agents/README.md` — surface commands, skills, subagents, and loops.
- `.gitignore` — track `.claude/` surfaces; ignore only `settings.local.json` and `worktrees/`.

### Tooling
- `scripts/verify-harness.sh` — added slash-command (§9), skill (§10), context-map (§11), and subagent (§12) schema checks; **15/15 checks pass**, `shellcheck` deferred to CI (not installed locally).

### Known Issues
- The implementation loop is `/build-loop`, not `/loop`, to avoid colliding with Claude Code's built-in `/loop` interval scheduler.

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
