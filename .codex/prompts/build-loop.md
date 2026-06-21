# build-loop — Bounded Implementation Loop

Implement a scoped task through a bounded loop — implement, verify, review, fix — repeating until a 10/10 PASS or the iteration cap (6 iterations).

## Task

$ARGUMENTS

## Procedure

Follow the `/build-loop` spec in [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md):

1. Read or create a sprint contract for `$ARGUMENTS` in `.agents/logs/progress.md`: goal, scope, acceptance criteria, and verification plan (lint / type-check / tests / build — as applicable).
2. Implement the smallest correct increment. Run the project's verification commands from `.agents/context/commands.md`. Capture output as evidence. Fix failures before advancing.
3. Run the review gate: have a reviewer role score the diff 1–10 using `evaluator-rubric.md` and return `PASS`, `REVISE`, or `BLOCK`. Follow the review workflow in [`.agents/workflows/review.md`](../../.agents/workflows/review.md).
4. Fix every Critical or Major finding before the next iteration.
5. Repeat steps 2–4. **Hard cap: 6 iterations total.**

## Stop Conditions

- **Success:** score is 10/10, verdict is `PASS`, and all acceptance criteria are met with captured verification evidence.
- **Cap reached (6 iterations):** stop. Document remaining issues; create follow-up items for unresolved Minor/Major findings. Do not extend the cap.
- **BLOCK verdict:** stop immediately. Document the blocker in full and escalate.

## Output

Emit this report when the loop ends:

```text
## Loop Report — <task>
- Iterations: <N> / 6
- Final Score: <X>/10 — Verdict: PASS | REVISE | BLOCK | CAP_REACHED
- Acceptance criteria: MET | PARTIAL | UNMET
- Verification: <commands run + pass/fail summary>
- Deferred findings: <list or "none">
- Handover: update session-handoff.md and .agents/logs/handover.md
```

## Hard Rules

- Never run more than 6 iterations.
- Never mark work done without captured verification evidence.
- Never commit or echo secrets.
- No LLM/AI attribution in commits, PRs, code, or docs.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
