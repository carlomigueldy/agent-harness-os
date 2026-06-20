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

## Retrospective — 2026-06-20 — Agent-native harness hardening

### Score
9/10 (self).

### Reviewer Verdict
PASS — 10/10 after one REVISE round (adversarial 3-dimension Opus review → fixes → independent re-review PASS).

### What Changed
- Added invokable `.claude/commands/` (24), `.claude/skills/` (12), model-tiered `.claude/agents/` (11); the autonomous-loop system; recursive context maps; extended `verify-harness.sh` (§9–§12) and entry-file indexes. 74 files, verify 15/15.

### What Went Well
- Reconcile-onto-`.agents/` decision avoided a duplicate `docs/` tree. Schema-enforcing CI + per-file Opus review + a final adversarial panel caught real defects deterministic checks can't.
- The adversarial review earned its cost: found a true BLOCKER (scout "read-only" but granting Bash) and a self-contradicting skill (wrong loop caps).

### What Was Difficult
- Coordinating two background workflows; the subagent fan-out **stalled at 1/11** and was completed by hand.

### Bugs / Risks Found
- scout read-only contract violated by `tools: …, Bash`; `autonomous-loop-design` caps contradicted the canonical source; `security-review` verdict vocab drift; `verify-harness.sh` couldn't enforce the read-only contract (now §12 does).

### Harness Gaps Found
- A "read-only" claim wasn't machine-checked → added the §12 tools-vs-claim guard. Heading checks were substring-based → anchored to line start.

### Skills / Superpowers Used
- `opus-code-review` pattern (review stages); the new project skills/subagents (dogfooded).

### Improvements for Next Time
- Background workflows under parallel load + session interruptions can stall; prefer fewer concurrent workflows or checkpoint/resume.

### Follow-up Proposals
- Consider a `verify-harness.sh` check that command files don't embed depth-wrong example links (the create-skill footer-example link broke once).

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
