# Progress Log

Detailed progress state for {{PROJECT_NAME}}. Read this at the start of every session. Update before ending every session. Active Sprint Contracts live here.

See also: [../../claude-progress.md](../../claude-progress.md) for the root-level summary.

---

## Current State

<!-- FILL: Update these fields every session. -->

| Field | Value |
|---|---|
| Phase | Implementation |
| Current Task | Portability & delivery hardening (runtime-agnostic, provisioning CLI, epic/ledger sync, worktree gitignore) |
| Branch | `harness/portability-hardening` (in-place epic branch) |
| Worktree Path | N/A — in-place branch (see decision 2026-06-21) |
| Last Verification | `scripts/verify-harness.sh` → 18/18 pass, 0 fail (2026-06-21) |
| Last Demo Artifact | verify-harness 18/0 + live `worktree.sh sync-exclude` ./claire test (2026-06-21) |
| Last Handover | See `../../session-handoff.md` |

---

## In Progress

- Portability & delivery hardening — see Active Sprint Contract below. Built by a 4-agent Sonnet fleet + Opus 10/10 review loop; ready for PR. Tracked in-repo (no GitHub tracking issues; the issue workflow is template content for adopters).

---

## Completed

<!-- FILL: Append completed tasks in reverse-chronological order. -->

- 2026-06-21 — Portability & delivery hardening (runtime-agnostic + provisioning CLI + epic/ledger sync + worktree gitignore). Reviewer PASS 10/10, safety PASS; verify-harness 18/0. PR pending.
- 2026-06-20 — Agent-native harness hardening (invokable commands/skills/subagents, autonomous loops, recursive context, review gates, schema CI). Reviewer PASS 10/10; merged (PR #8).
- 2026-06-03 — Harden harness template repo (README + self-verifying CI). Reviewer PASS 10/10; merged (PR #4).

---

## Blocked

<!-- FILL: List blockers with context about why and what unblocks them. -->

— none —

---

## Next Best Action

<!-- FILL: Specific, actionable next step for the next session. -->

1. Read this file and [../../claude-progress.md](../../claude-progress.md).
2. Check [../../feature_list.json](../../feature_list.json) for the highest-priority unfinished item.
3. Create a Sprint Contract below before starting implementation.

---

## Open Issues / PRs

<!-- FILL: Links to relevant GitHub issues and PRs. -->

— none —

---

## Known Risks

<!-- FILL: Any risks the next session should be aware of. -->

— none —

---

## Sprint Contracts

Active and recent sprint contracts live here. Archive old ones below under "Completed Sprint Contracts".

### Sprint Contract Format

```md
## Sprint Contract — Task Name

### Goal
What needs to be achieved.

### Scope
What will be changed.

### Non-goals
What will not be changed.

### Acceptance Criteria
- ...

### Verification Plan
- ...

### Demo Plan
- ...

### Dependencies
- ...

### Blockers
- ...

### Worktree
Branch/path/env status.

### Skills / Superpowers
Relevant skill usage.

### Orchestration Mode
Single agent / subagent / agent team / dynamic workflow / sequential manual.

### Parallelization Assessment
Sequential required / parallel-safe.

### Risk Level
Low / medium / high.

### Model Tier
Haiku / Sonnet / Opus-level.

### Done Means
Clear definition of done.
```

---

<!-- FILL: Paste active sprint contract below this line. Archive completed contracts under "Completed Sprint Contracts". -->

### Active Sprint Contract

## Sprint Contract — Portability & delivery hardening

**Status:** Implemented; Opus review PASS 10/10 + safety PASS; verify-harness 18/0. Ready for PR (2026-06-21).

### Goal
Make the harness portable across agent runtimes (Claude Code + Codex + generic) without duplicating doctrine; automate adoption with a provisioning CLI; close the epic-branch sub-issue auto-close gap and bind agent tasks to the `feature_list.json` ledger; guarantee in-repo worktree dirs are never committed.

### Scope
NEW: `.agents/context/runtimes.md`, `.codex/` adapter (AGENTS.md/README.md/prompts/build-loop.md), `scripts/provision.sh`, `harness.config.example`, `.github/workflows/epic-sync.yml`, `scripts/sync-ledger.sh`, `.agents/workflows/epic-delivery.md`, `.claude/commands/sync-ledger.md`, `scripts/worktree.sh`. EDIT (owned): `init.sh` (6 new stack detectors), `.gitignore` (in-repo worktree block), `feature_list.json` (`epic` field). Integrator edits to shared entry/index docs.

### Non-goals
Filling template placeholders (that is adoption); generating the full Codex prompt set (one example only); creating GitHub tracking issues on the template repo; project-specific stack content.

### Acceptance Criteria
- `runtimes.md` + usable `.codex/` adapter; no doctrine duplication; stack detection broadened to 9 ecosystems.
- `provision.sh` automates placeholder fill + stack detect + verify, with safe `--dry-run`, non-interactive path, refuse-to-clobber, no `eval` of config.
- `epic-sync.yml` closes sub-issues on epic-branch PR merge (guarded off `main`, least-privilege, injection-safe); `sync-ledger.sh` reconciles ledger↔issues and degrades without `gh`; `/sync-ledger` conforms to schema; `epic-delivery.md` documents the contract; `feature_list.json` stays a clean example.
- In-repo worktrees ignored incl. arbitrary names via `worktree.sh sync-exclude`; sibling/in-repo convention reconciled.
- verify-harness 18/0; AGENTS.md ≤ 200, CLAUDE.md ≤ 250; links resolve; no attribution; no secrets; scripts pass `bash -n`.

### Verification Plan
- `bash scripts/verify-harness.sh` → 18/0; `bash -n` all scripts; `bash init.sh`; `provision.sh --dry-run` (no mutation); `sync-ledger.sh` (graceful); live `worktree.sh sync-exclude` ./claire test.

### Orchestration Mode
- Dynamic workflow: 4 parallel Sonnet implementers (disjoint files) → 1 Sonnet integrator (shared files) → Opus reviewer + safety-reviewer gate with Sonnet fixer (10/10 loop, max 4). Single PR; second Opus review loop on the PR diff before merge.

### Parallelization Assessment
- Parallel-safe: implementers own strictly disjoint file sets; shared entry/index files edited only by the sequential integrator.

### Risk Level
- Medium (new automation scripts + a GitHub Action; mitigated by safety review + schema CI + live tests).

### Model Tier
- Sonnet for implementation/integration/fixes; Opus for review + safety gates.

### Done Means
- Acceptance criteria met, verify-harness green, logs updated, single PR opened + PR-diff Opus review PASS, merged into `main`.

---

### Completed Sprint Contracts

## Sprint Contract — Agent-native harness hardening

**Status:** Complete — shipped 2026-06-20 (PR #8); reviewer PASS 10/10.

### Goal
Turn described workflows into invokable capability: real `.claude/commands/` slash commands and `.claude/skills/` project skills, a formal `autonomous-loops` system, recursive context maps, strict Opus review gates, and schema-validating CI — reconciled onto `.agents/` (no duplicate `docs/` tree).

### Scope
Add `.claude/commands/` (core command set), `.claude/skills/` (core skill set), `.claude/README.md`, `.claude/skills/AGENTS.md`; new `.agents/workflows/autonomous-loops.md` + `.agents/workflows/context-mapping.md`; new `.agents/context/slash-commands.md` + `.agents/context/failure-modes.md`; extend `.agents/context/skills.md`, `.agents/workflows/review.md`, `.agents/workflows/github-issues.md`, `evaluator-rubric.md`; recursive `AGENTS.md` in `.github/`, `scripts/`, `.agents/`; extend `scripts/verify-harness.sh` + `.github/workflows/ci.yml`; update root `README.md` / `AGENTS.md` / `CLAUDE.md` / `.agents/README.md`; add root `CONTRIBUTING.md`.

### Non-goals
A parallel `docs/` tree; project-specific stack content; weakening existing constraints; creating GitHub tracking issues on the template repo.

### Acceptance Criteria
- Core `.claude/commands/` exist, each conforming to the command schema; namespace clean (no stray `.md`).
- Core `.claude/skills/` exist, each `SKILL.md` conforming to the skill schema (frontmatter `name`/`description`, `name` == dir).
- `autonomous-loops.md` defines every loop with bounded iterations + stop/escalation/handoff/recovery.
- Recursive context files present in key subdirs.
- Review gates + 10/10 strict rule documented and referenced by review commands.
- `verify-harness.sh` validates command/skill/context schemas and exits 0; `shellcheck --severity=error` clean; all relative links resolve.
- Root entry files surface the new surfaces; entry-file length limits respected (AGENTS.md ≤ 200, CLAUDE.md ≤ 250).
- No AI/LLM attribution; no secrets.

### Verification Plan
- `bash scripts/verify-harness.sh` → exit 0 (extended checks).
- `shellcheck --severity=error scripts/*.sh init.sh`.
- Markdown link resolution (built into verify-harness.sh).
- Fresh-session test: a new agent can discover + invoke commands/skills from the repo alone.

### Demo Plan
- Paste verify-harness.sh output into `../logs/verification.md`; list `/help`-discoverable command count.

### Dependencies
- None (builds on the existing harness).

### Blockers
- None.

### Worktree
- In-place epic branch `harness/agent-native-hardening`. No env files needed. (See decision 2026-06-20.)

### Skills / Superpowers
- Architect/integrator inline; dynamic workflows for fan-out generation of command/skill files; Opus reviewer gates.

### Orchestration Mode
- Hybrid: inline authoring of schemas/exemplars/backbone; dynamic workflow fan-out for the high-volume schema-bound files; Opus-led review loop. Justified by file volume (40+) and clean partition (distinct files per worker).

### Parallelization Assessment
- Parallel-safe: each generated command/skill/context file is a distinct path → no conflict. Backbone + index edits done sequentially by the integrator.

### Risk Level
- Medium (broad surface; mitigated by schema-enforcing CI + review gates).

### Model Tier
- Opus-level for architecture, schemas, and review gates; Sonnet-level for schema-bound file generation.

### Done Means
- All acceptance criteria met, verify-harness.sh green, logs + `feature_list.json` (no template pollution) updated, handover written, single PR opened.

---

## Sprint Contract — Harden harness template repo (README + self-verifying CI)

**Status:** Complete — verification 11/11, reviewer PASS 10/10, merged via PR #4 (2026-06-03).

### Goal
Make the template shareable and self-checking: a root README landing page plus a CI-backed verification script that is the single source of verification truth.

### Scope
Add `README.md`, `scripts/verify-harness.sh`, `.github/workflows/ci.yml`. Update harness logs and `feature_list.json`.

### Non-goals
Filling template placeholders (that is adoption); adding a LICENSE; altering existing harness docs beyond what verification requires.

### Acceptance Criteria
- README renders on GitHub, all relative links resolve, links to `adoption.md`.
- `bash scripts/verify-harness.sh` exits 0 locally and in CI.
- CI is green on the PR; no AI attribution; no secrets; clean state.

### Verification Plan
- Run `scripts/verify-harness.sh` locally and capture output.
- Confirm the CI run is green on the PR.

### Demo Plan
- Paste verify-harness.sh CLI output into `../logs/verification.md`; link the green CI run in the PR.

### Dependencies
- Epic #1; sub-issues #2 (README), #3 (CI).

### Blockers
- None.

### Worktree
- Branch `harness/repo-hardening` at `../agent-harness-templates-worktrees/harness/repo-hardening`. No env files needed.

### Skills / Superpowers
- Single-agent implementation; reviewer subagent for the 10/10 review loop.

### Orchestration Mode
- Single agent (sequential) + independent reviewer subagent. Multi-agent orchestration is not justified for a small docs+CI change (see `../workflows/orchestration.md`).

### Parallelization Assessment
- README and CI are parallel-safe (separate files) but small enough to do sequentially in one context.

### Risk Level
- Low.

### Model Tier
- Sonnet-level implementation; Opus-level final review.

### Done Means
- All acceptance criteria met, CI green, logs + `feature_list.json` updated, PR merged into `main`, worktree cleaned.

---

## Progress History

<!-- FILL: Append session summaries in reverse-chronological order. -->

### YYYY-MM-DD — Session Summary

- Phase: —
- Completed: —
- In progress: —
- Blocked: —
- Next: —

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
