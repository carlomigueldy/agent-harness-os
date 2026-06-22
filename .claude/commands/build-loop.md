---
description: Bounded implementation loop (max 6) that iterates to a 10/10 PASS
argument-hint: "[task]"
---

# /build-loop

> Implement a scoped task through a bounded loop — implement, verify, review, fix — repeating until a 10/10 PASS or the iteration cap.

## Purpose

Use this when you have a well-scoped task and want a disciplined, self-correcting loop. Each iteration implements the next increment, verifies it, runs the `/review-10x` gate, and fixes Critical/Major findings. Max **6 iterations**.

Task: **$ARGUMENTS**

## Usage

`/build-loop <task>` — e.g. `/build-loop add input validation to the registration form`.

If `$ARGUMENTS` is empty, ask for it before starting.

## Preconditions

- On a feature branch or worktree, not `main`/`master`.
- Acceptance criteria are defined or derivable from `$ARGUMENTS` and the sprint contract in [`.agents/logs/progress.md`](../../.agents/logs/progress.md).
- Verification commands confirmed from [`.agents/context/commands.md`](../../.agents/context/commands.md).

## Procedure

Confirm the sprint contract, implement the next increment, verify, run `/review-10x`, fix Critical/Major findings. Repeat. Full schema: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) + [`.agents/workflows/implementation.md`](../../.agents/workflows/implementation.md).

## Stop Conditions

PASS at 10/10 with all acceptance criteria met; CAP_REACHED at iteration 6; BLOCK on unresolvable Critical. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Never weaken checks, commit secrets, or mark done without evidence. Keep diffs small and reviewable. Full rules: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Output

Emits a Loop Report. Schema, stop conditions, safety rules, and Loop Report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Full implementation guidance: [`.agents/workflows/implementation.md`](../../.agents/workflows/implementation.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md), [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`implementation.md`](../../.agents/workflows/implementation.md)
- **Commands:** `/review-10x`, `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
