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

## 2026-06-21

### Added
- **Runtime portability layer** — the harness is now explicitly portable across agent runtimes without duplicating doctrine. New `.agents/context/runtimes.md` (core-vs-adapter model + a Claude Code / Codex / Generic mapping table + the adapter contract) and a `.codex/` adapter (`AGENTS.md`, `README.md`, `prompts/build-loop.md`) that points back into `.agents/`. `CLAUDE.md` is now named as the Claude Code *adapter*.
- **Provisioning CLI** — `scripts/provision.sh` automates adoption (placeholder fill + stack detection + `verify-harness`), with a write-nothing `--dry-run`, a non-interactive/`--config` path (safe parse, no `eval`/`source`), a refuse-to-clobber guard, and `--runtime claude|codex|both|generic`. `harness.config.example` documents the config. `adoption.md`/README now point to it.
- **Epic-branch sub-issue closing + ledger sync** — `.github/workflows/epic-sync.yml` closes sub-issues GitHub does not auto-close when a PR merges into an `epic/*` branch (guarded so it never fires on `main`; least-privilege; injection-safe). `scripts/sync-ledger.sh` reconciles `feature_list.json` ↔ GitHub issues (report-only by default; cautious `--fix`; degrades gracefully without `gh`). New `/sync-ledger` command and `.agents/workflows/epic-delivery.md` workflow; `feature_list.json` example gains an `epic` field.
- **Safe worktree helper** — `scripts/worktree.sh` (`create`/`list`/`remove`/`prune`/`sync-exclude`) with branch-prefix validation, gitignore-verified env copy (never staged, never printed), and a `sync-exclude` catch-all that excludes **any** in-repo worktree (incl. hand-made `./claire`) via `.git/info/exclude`.
- **`parallel-epic-delivery` project skill** — `.claude/skills/parallel-epic-delivery/SKILL.md` (skills now total 13). A stack-agnostic orchestration pattern for shipping N independent epics concurrently: one git worktree + Workflow lane each (Sonnet implements, Opus drives a strict 10/10 review loop, then PR + adversarial PR-diff review), followed by integration-verification of the *combined* tree and dependency-ordered merges that keep `main` green after every step. Composes the existing single-lane loops (`autonomous-loop-design`, `opus-code-review`) into a fan-out and adds the one thing per-lane loops can't: verification of the merged result before anything lands. Indexed in [`../context/skills.md`](../context/skills.md).

### Changed
- `init.sh` — stack detection broadened from 4 to **9 ecosystems** (added Ruby/bundler, PHP/composer, Java/Maven, Java/Gradle, .NET, Elixir/mix) following the existing detection pattern; `Next steps` points adopters at `provision.sh`.
- `.gitignore` — replaced the bare "worktrees live outside the tree" note with a documented in-repo worktree block (`/worktrees/`, `/.worktrees/`, `.git/info/exclude` guidance for arbitrary names).
- Shared entry/index docs (`AGENTS.md`, `CLAUDE.md`, `README.md`, `.agents/README.md`, `slash-commands.md`, `skills.md`, `subagents.md`, `github-issues.md`, `worktrees.md`, `worktree-sessions.md`, `adoption.md`, `scripts/AGENTS.md`, `.github/AGENTS.md`) — surface the new runtime/provisioning/epic/worktree capabilities (entry-file length limits respected: AGENTS.md 189/200, CLAUDE.md 217/250).

### Tooling
- `scripts/verify-harness.sh` continues to pass **18/18** with the new command (`/sync-ledger`), scripts, and the `epic-sync.yml` workflow YAML. No verifier changes required (new surfaces auto-covered by existing schema checks §4/§8/§9).

### Docs
- New `.agents/context/runtimes.md` and `.agents/workflows/epic-delivery.md`; `.codex/` adapter docs — all cross-linked into `.agents/README.md`.

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
