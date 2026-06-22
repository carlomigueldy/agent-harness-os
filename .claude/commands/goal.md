---
description: "Goal-driven loop: define acceptance criteria, then iterate to done (max 6)"
argument-hint: "[goal]"
---

# /goal

> Reach a stated goal whose steps are not fully known up front by first defining measurable acceptance criteria, then iterating to them under a bounded loop.

## Purpose

Use this when you have a clear destination but not a fully spelled-out plan. Forces acceptance criteria to be written before any edit is made, then drives a structured iterate-and-verify loop. Max **6 iterations**; escalates on stall (no criterion advanced in 2 consecutive iterations).

Goal: **$ARGUMENTS**

## Usage

`/goal <goal description>` — e.g. `/goal make the CI pipeline pass with zero lint and type errors`.

If `$ARGUMENTS` is empty or underspecified, ask before proceeding.

## Preconditions

- On a feature branch or worktree, not the default branch.
- Relevant context read: [`AGENTS.md`](../../AGENTS.md).

## Procedure

Write measurable acceptance criteria first. Take one step per iteration, run verification, mark criteria met. Full schema: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) + [`.agents/workflows/planning.md`](../../.agents/workflows/planning.md).

## Stop Conditions

PASS when all criteria are met with evidence; STALLED if no criterion advances in 2 consecutive iterations; CAP at 6; BLOCKED on irreversible/outward-facing action with no safe default. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Write acceptance criteria before any edit. Never start iterating on an undefined goal. Never commit secrets or weaken validation to satisfy a criterion.

## Output

Emits a Goal report with acceptance criteria status and verdict (PASS / STALLED / BLOCKED). Schema, stop conditions, safety rules, and report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Sprint contract guidance: [`.agents/workflows/planning.md`](../../.agents/workflows/planning.md).

## Related

- **Skills:** [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`planning.md`](../../.agents/workflows/planning.md)
- **Commands:** `/build-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
