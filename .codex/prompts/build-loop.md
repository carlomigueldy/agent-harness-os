# build-loop — Bounded Implementation Loop

Implement a scoped task through a bounded loop — implement, verify, review, fix — repeating until a 10/10 PASS or the iteration cap (6 iterations).

## Task

$ARGUMENTS

## Procedure

Follow the full `/build-loop` spec in [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) — loop schema, iteration caps, stop conditions, and safety rules all live there.

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

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
