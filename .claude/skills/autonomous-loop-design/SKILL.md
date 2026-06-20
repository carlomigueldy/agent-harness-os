---
name: autonomous-loop-design
description: Design a bounded autonomous loop with iteration cap, stop and escalation conditions, a review gate, and a handoff
---

# Skill: autonomous-loop-design

## Purpose

Design or instantiate a safe autonomous loop that converges without running forever or shipping unverified work. Apply this skill to produce a loop contract — a short document that fixes the class, cap, stop/escalation conditions, review gate, logging, and handoff format before any agent starts iterating. The contract is the guard against runaway execution and silent failure.

Full loop execution protocol: [`../../../.agents/workflows/autonomous-loops.md`](../../../.agents/workflows/autonomous-loops.md)

## When to Use

- Setting up any repeating agent process: implementation, fix, test, review, docs, or discovery.
- Choosing an iteration cap before a loop starts.
- Deciding stop conditions and escalation triggers for a loop that could stall or diverge.
- Reviewing an existing loop for safety gaps before running it autonomously.
- Composing a loop with a review gate (e.g., pairing with [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) as the gate each iteration must pass).

## When Not to Use

- Single-pass tasks with no iteration — write a sprint contract instead, not a loop contract.
- Workflows that require a human gate at every step — a human-in-the-loop approval flow is not an autonomous loop; model it as a workflow with explicit pause points.
- Discovery or brainstorm phases where the number of passes is genuinely open-ended and a human will supervise each step.

## Inputs

- **Goal statement:** what the loop must accomplish (one sentence, verifiable).
- **Loop class:** one of `implementation`, `fix`, `review`, `test`, `docs`, `discovery`.
- **Acceptance criteria:** the condition(s) that constitute a passing iteration.
- **Escalation owner:** who or what receives control when the loop cannot converge (a human, a higher-tier agent, or an upstream orchestrator).
- Optionally: an existing sprint contract or issue the loop is executing against.

## Outputs

- A **loop contract** (recorded in [`../../../.agents/logs/progress.md`](../../../.agents/logs/progress.md) or the relevant sprint log) containing:
  - Loop class and iteration cap
  - Inputs, outputs, stop conditions, escalation triggers
  - Review gate definition (what must pass each iteration)
  - Logging format and handoff artifact
- Confirmation that the loop cannot run unbounded (cap verified).

## Procedure

1. **Classify the loop and set the cap.**
   Identify the class from the table below and adopt the default cap. Override only with explicit justification recorded in the contract.

   | Class | Default cap | Notes |
   |---|---|---|
   | `implementation` | 6 iterations | One feature unit; escalate if not converging by iteration 4 |
   | `fix` | 10 iterations | Bug/regression or failing check; stop and escalate if the same failure repeats with no new hypothesis |
   | `review` | 10 iterations | REVISE→fix→re-review until 10/10 PASS |
   | `test` | 6 iterations | Write/fix until the suite is green; never weaken a test to pass |
   | `docs` | 4 iterations | Update until accurate and all links resolve |
   | `discovery` | 3 iterations | Bounded research pass; stop after two dry rounds |

   > These match the canonical caps in [`../../../.agents/workflows/autonomous-loops.md`](../../../.agents/workflows/autonomous-loops.md) — keep them in step.

2. **Define inputs, outputs, stop conditions, and escalation triggers.**
   Write each as a concrete, checkable statement — not vague intent.

   - **Stop (success):** "All acceptance criteria pass and the review gate returns `PASS` at 10/10."
   - **Stop (cap reached):** "Iteration N completed with no PASS — loop halts, escalates."
   - **Escalation triggers (mid-loop):** broken environment, irreversible action required, security finding, scope change detected, or repeated identical failure across two consecutive iterations.
   - **Escalation target:** name the owner (human via `/ask`, orchestrator, higher-tier agent).

   Do not leave escalation undefined. A loop without an escalation path is a runaway loop.

3. **Wire the review gate.**
   Every iteration ends with a gate check before the loop may advance. For non-trivial loops, the gate is [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) run in strict mode (10/10 + zero Critical/Major = `PASS`). For lighter loops (docs, discovery), define a lighter gate — but define it explicitly. Record:

   - What the gate checks (acceptance criteria + rubric dimensions relevant to the loop class).
   - Who runs the gate (same agent, reviewer agent, or human).
   - What a `REVISE` verdict requires (exact remediation, not "fix the issues").
   - What a `BLOCK` verdict requires (halt + escalate immediately, never retry).

4. **Define logging and the end-of-loop handoff.**
   Each iteration appends a structured log entry to [`../../../.agents/logs/progress.md`](../../../.agents/logs/progress.md):

   ```
   ## Loop: {{LOOP_GOAL}} — Iteration N / CAP
   - Status: PASS | REVISE | BLOCK | ESCALATE
   - Gate score: N/10
   - Findings: <Critical/Major/Minor/Nit summary>
   - Files changed: <list>
   - Commands run: <list>
   - Next action: <continue | fix | escalate | halt>
   ```

   At loop end (PASS or cap), write the handoff artifact using [`../../../.agents/workflows/autonomous-loops.md`](../../../.agents/workflows/autonomous-loops.md) and update `session-handoff.md` if this is a session boundary.

5. **Confirm the loop cannot run unbounded.**
   Before starting, verify:
   - The cap is a finite integer recorded in the contract.
   - Every code path through the loop (success, REVISE, BLOCK, escalation trigger) leads to a defined exit.
   - No retry logic silently resets the counter.
   - The escalation path reaches a human or a higher authority before the cap is exhausted if any mid-loop trigger fires.

   If any path is open-ended, close it or refuse to start the loop.

## Checks

- Loop contract is written and recorded before any iteration begins.
- Cap is finite and matches the class default (or override is justified).
- All four exit paths are defined: success, cap-reached, BLOCK, mid-loop escalation.
- Review gate references concrete acceptance criteria, not vague quality intent.
- Escalation owner is named and reachable (not a dead-end).
- Logging format is consistent and appended each iteration — not only on failure.
- No AI/LLM attribution in any commit, PR, or artifact produced by the loop.

## Common Failure Modes

- **No cap defined.** The loop runs until the environment times out or the agent exhausts context. Always set a finite cap before starting.
- **Vague stop conditions.** "Looks good" is not a stop condition. Tie the stop condition to a verifiable check (test green, gate returns PASS at 10/10, lint clean).
- **Missing escalation path.** A `BLOCK` verdict or repeated REVISE with no escalation means the loop stalls silently. Name the escalation target.
- **Gate not run each iteration.** Skipping the gate because "it probably passes" accumulates unverified work. The gate is mandatory every iteration.
- **Counter reset in a retry.** An inner retry that resets the iteration counter defeats the cap. Count all attempts against the cap.
- **Scope creep mid-loop.** A new requirement surfaces; the agent continues without updating the contract. Stop, update the contract (or escalate), then continue.

## Example Usage

> Goal: "Fix all failing unit tests in `{{MODULE}}`."
> Class: `fix` → cap: 10 iterations.
> Stop (success): test suite exits 0, gate returns PASS.
> Stop (cap): 10 iterations complete, tests still failing → escalate via `/ask`.
> Gate: `/review-10x` on the diff each iteration; BLOCK halts immediately.
> Escalation triggers: test environment broken, flaky infrastructure test (not a logic bug), or same failure repeated twice.
>
> Iteration 1: fix 3 tests, 2 remain → REVISE.
> Iteration 2: fix 1 test, 1 remains → REVISE.
> Iteration 3: fix last test, suite green → gate returns PASS 10/10 → PASS. Handoff written.

## Related Commands

`/autonomous-loop`, `/build-loop`, `/goal`

## Maintenance Notes

Keep the class/cap table in step with [`../../../.agents/workflows/autonomous-loops.md`](../../../.agents/workflows/autonomous-loops.md). If a new loop class is added to the workflow, add a row here. If the review gate rubric changes, update step 3 to match [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md).

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
