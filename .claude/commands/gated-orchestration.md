---
description: Plan, decompose, delegate, and review a non-trivial task through explicit approval and review gates
argument-hint: [task description]
model: opus
---

# /gated-orchestration

> Drive a non-trivial task from intent to verified completion through explicit gates, choosing the lightest orchestration mode that still produces 10/10 work.

## Purpose

Use this when a task is big, ambiguous, high-risk, or spans multiple files. Enforces plan → decompose → delegate → review flow with gates at each stage so nothing ships unverified.

Task: **$ARGUMENTS**

## Usage

`/gated-orchestration <task description>` — e.g. `/gated-orchestration migrate the auth module to the new session API`.

If `$ARGUMENTS` is empty, ask before proceeding.

## Preconditions

- Repo state is understood (`git status`); on a feature branch or worktree, not the default branch.
- Relevant context read: [`AGENTS.md`](../../AGENTS.md).

## Procedure

Frame → Plan (gate 1, sprint contract) → Choose mode (decision matrix) → Decompose → Delegate & implement → Review via `/review-10x` (gate 2) → Integrate & verify (gate 3) → Hand off. Full procedure: [`.agents/workflows/orchestration.md`](../../.agents/workflows/orchestration.md) + [`.agents/workflows/planning.md`](../../.agents/workflows/planning.md).

## Stop Conditions

PASS: acceptance criteria met, 10/10 PASS, verification evidence captured. Escalate on irreversible/outward-facing actions with no safe default, unresolvable blockers, or loop cap exhausted. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Confirm before destructive/outward-facing actions. Never weaken auth or validation; never commit secrets. Do not force parallelism when work shares files, contracts, or migrations.

## Output

Emits an Orchestration report (mode, plan link, units, verification, review verdict, follow-ups, handover). Orchestration mode decision matrix and hard limits: [`.agents/workflows/orchestration.md`](../../.agents/workflows/orchestration.md). Sprint contract format: [`.agents/workflows/planning.md`](../../.agents/workflows/planning.md). Loop caps and stop conditions: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Review procedure: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md), [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`orchestration.md`](../../.agents/workflows/orchestration.md), [`planning.md`](../../.agents/workflows/planning.md), [`agent-teams.md`](../../.agents/workflows/agent-teams.md), [`dynamic-workflows.md`](../../.agents/workflows/dynamic-workflows.md)
- **Commands:** `/review-10x`, `/build-loop`, `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
