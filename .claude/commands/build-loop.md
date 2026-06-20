---
description: Bounded implementation loop (max 6) that iterates to a 10/10 PASS
argument-hint: "[task]"
---

# /build-loop

> Implement a scoped task through a bounded loop — implement, verify, review, fix — repeating until a 10/10 PASS or the iteration cap.

## Purpose

Use this when you have a well-scoped task and want a disciplined, self-correcting loop that won't run forever. The loop runs at most 6 iterations: each iteration implements the next increment, verifies it, sends it through the strict review gate, and fixes what the reviewer flags — stopping only when the reviewer returns `PASS` at 10/10, or when the cap is reached.

Task: **$ARGUMENTS**

## Usage

`/build-loop <task>` — e.g. `/build-loop add input validation to the registration form`.

## Parameters

- `$ARGUMENTS` (required) — the scoped task or sub-task in one or two sentences. If empty, ask for it before starting.

## Preconditions

- You are on a feature branch or worktree, not `main` / `master`.
- `git status` is clean (or staged changes are understood and intentional).
- Acceptance criteria are defined or can be derived from `$ARGUMENTS` and the sprint contract in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md).
- Verification commands for this project are known; confirm from [`../../.agents/context/commands.md`](../../.agents/context/commands.md) if uncertain.

## Procedure

1. **Confirm acceptance criteria (sprint contract).** Read the existing sprint contract in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md). If no contract exists for this task, write one now: goal, scope, non-goals, acceptance criteria, verification plan (lint / typecheck / tests / build / screenshot — as applicable to the change type), and the definition of done. Surface any unknowns; if a decision is irreversible or outward-facing with no safe default, stop and ask before proceeding.

2. **Implement the next increment and verify.** Write the smallest correct implementation that advances toward the acceptance criteria. After writing, run the full verification plan from the sprint contract: lint, typecheck, tests, build, or any project-specific checks. Capture command output as evidence. If verification fails, fix within this step before advancing to the review gate — do not submit a failing increment for review.

3. **Run the review gate (`/review-10x`) and fix Critical/Major findings.** Invoke `/review-10x` against the current diff. Read the returned score and verdict. Fix every finding rated Critical or Major before the next iteration begins. Nit-level findings may be deferred to a follow-up issue. Log the score, verdict, and any deferred findings in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md). If the verdict is `BLOCK`, stop the loop, document the blocker, and escalate.

4. **Repeat steps 2–3 up to 6 iterations total.** Each iteration starts from the current verified state and builds on it. Track the iteration count explicitly. Do not restart the count; the cap is global across all iterations of this invocation.

5. **Emit the Loop Report and produce a handoff.** When the loop exits — either because the reviewer returned `PASS` at 10/10 or the cap was reached — emit the Loop Report (see **Output**) and run `/final-handoff` to produce the compact session handover. If the cap was reached without a PASS, document the remaining findings, create follow-up issues for unresolved Minor/Major items, and record the final state in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md).

## Stop Conditions

- **Success:** reviewer verdict is `PASS` at `Score: 10/10` and all acceptance criteria are met with captured verification evidence.
- **Cap reached:** 6 iterations completed without a PASS — stop, emit the Loop Report with `Verdict: CAP_REACHED`, document remaining issues, and create follow-up issues.
- **Blocked:** reviewer verdict is `BLOCK`, or a Critical finding cannot be resolved in-session — stop immediately, document the blocker in full, and escalate.
- **Irreversible action required:** a step requires a destructive, outward-facing, or production action (delete, migration, publish, force-push) — stop and confirm with the user before proceeding.
- Never extend past 6 iterations to reach PASS — the cap is a hard stop. See [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) for the loop system and stop-condition doctrine.

## Safety

- Confirm before any destructive or outward-facing action (delete, force-push, migration, publish, send).
- Never commit or echo secrets. Never weaken auth, validation, rate limits, or permission checks to make verification pass.
- No AI/LLM attribution in any commit, PR, code, or doc.
- Keep diffs small and reviewable — if a single increment grows too large, decompose it before submitting to the review gate.
- Do not mark the task done without captured verification evidence; evidence before claims is non-negotiable.

## Output

Emit a Loop Report at the end of every run:

```md
## Loop Report — <task>
- Iterations: <N> / 6
- Final Score: <X>/10 — Verdict: PASS | REVISE | BLOCK | CAP_REACHED
- Acceptance criteria: MET | PARTIAL | UNMET
- Verification: <commands run + pass/fail summary>
- Deferred findings: <list or "none">
- Follow-up issues: <links or "none">
- Handover: <link to handoff entry>
```

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md), [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`implementation.md`](../../.agents/workflows/implementation.md)
- **Commands:** `/review-10x`, `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
