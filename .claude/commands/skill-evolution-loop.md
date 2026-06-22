---
description: Scan recent work for repeated workflows; propose or create skills (max 3)
---

# /skill-evolution-loop

> Find repeated workflows in recent session history and propose or create reusable skills from them.

## Purpose

Use this after active development to surface patterns worth encoding as durable skills or commands. Scans session logs, scores candidates (reuse × generality × novelty), takes the top 3, and either creates the skill immediately via `/create-skill` or files a proposal. Max **3 iterations**; stops after 2 consecutive dry rounds.

## Usage

`/skill-evolution-loop` — no arguments; operates on existing logs in the current repo.

## Preconditions

- At least one session log or handover entry exists in [`.agents/logs/`](../../.agents/logs/) or [`session-handoff.md`](../../session-handoff.md).
- Read access to [`.claude/skills/`](../../.claude/skills/) to check for existing skills before proposing new ones.

## Procedure

Scan logs, score candidates on reuse × generality × novelty, take top 3, create or propose each. Full schema: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Skill authoring: [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md).

## Stop Conditions

All candidates created or proposed; 2 consecutive dry rounds; CAP at 3 iterations. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Do not create skills without log evidence of real recurrence. Proposals touching global harness config require approval before action.

## Output

Emits a Skill Evolution report per iteration (candidates considered, decisions, dry-round count). Schema, stop conditions (dry-round stop, cap), safety rules, and report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Skill authoring procedure: [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md).

## Related

- **Skills:** [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md)
- **Commands:** `/create-skill`, `/create-command`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
