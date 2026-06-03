# Progress Log

Detailed progress state for {{PROJECT_NAME}}. Read this at the start of every session. Update before ending every session. Active Sprint Contracts live here.

See also: [../../claude-progress.md](../../claude-progress.md) for the root-level summary.

---

## Current State

<!-- FILL: Update these fields every session. -->

| Field | Value |
|---|---|
| Phase | Implementation |
| Current Task | Harden harness template repo (README + self-verifying CI) |
| Branch | `harness/repo-hardening` |
| Worktree Path | `../agent-harness-templates-worktrees/harness/repo-hardening` |
| Last Verification | `scripts/verify-harness.sh` (this sprint) |
| Last Demo Artifact | CI run + verify-harness.sh output (this sprint) |
| Last Handover | See `../../session-handoff.md` |

---

## In Progress

- Epic #1 — Harden harness template repo (README + self-verifying CI). Sub-issues #2 (README), #3 (CI).

---

## Completed

<!-- FILL: Append completed tasks in reverse-chronological order. -->

— none —

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

## Sprint Contract — Harden harness template repo (README + self-verifying CI)

**Status:** Complete — verification 11/11, reviewer PASS 10/10, PR #4 open (2026-06-03).

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

### Completed Sprint Contracts

<!-- FILL: Move completed sprint contracts here with a completion date note. -->

— none —

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
