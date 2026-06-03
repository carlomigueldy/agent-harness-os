# Retrospective Archive

Completed retrospectives for {{PROJECT_NAME}}, newest first. Append one after every meaningful completed task.

## Format

```md
## Retrospective — YYYY-MM-DD — Task Name

### Score
Self-score out of 10.

### Reviewer Verdict
PASS / REVISE / BLOCK.

### What Changed
- ...

### What Went Well
- ...

### What Was Difficult
- ...

### Bugs / Risks Found
- ...

### Harness Gaps Found
- ...

### Worktree / Env Notes
- ...

### Skills / Superpowers Used
- ...

### Improvements for Next Time
- ...

### Follow-up Proposals
- ...
```

See [../workflows/retrospectives.md](../workflows/retrospectives.md) for the full retrospective workflow.

---

<!-- FILL: Append new retrospective entries below in reverse-chronological order (newest first). -->

## Retrospective — 2026-06-03 — Harden harness template repo

### Score
9/10 (self).

### Reviewer Verdict
PASS (10/10, round 2).

### What Changed
- Added `README.md`, `scripts/verify-harness.sh`, `.github/workflows/ci.yml`; dogfooded the full harness loop (issues → worktree → sprint contract → implement → verify → review → logs → PR).

### What Went Well
- The review loop caught real verification-script bugs; fixes were quick and adversarially re-verified.
- Single-source verify script keeps local == CI.

### What Was Difficult
- Making a self-referential scanner correct: `verify-harness.sh` matches the very strings it contains, so it needed a path-anchored self-exclusion.

### Bugs / Risks Found
- `verify-harness.sh` false-negative paths (M1/M2/m1/m2) — all fixed.
- `.gitignore` `logs/` had been swallowing `.agents/logs/` (fixed before commit).

### Harness Gaps Found
- None new this sprint (the adoption-guide gap was fixed in the prior fresh-session pass).

### Worktree / Env Notes
- Worked in a dedicated worktree; no env files required.

### Skills / Superpowers Used
- Reviewer subagent for the 10/10 loop.

### Improvements for Next Time
- Write self-referential scanners with path-anchored exclusions from the start.

### Follow-up Proposals
- Optional: SHA-pin GitHub Actions; add a markdown formatting lint.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
