---
description: Plan, decompose, delegate, and review a non-trivial task through explicit approval and review gates
argument-hint: [task description]
model: opus
---

# /gated-orchestration

> Drive a non-trivial task from intent to verified completion through explicit gates, choosing the lightest orchestration mode that still produces 10/10 work.

## Purpose

Use this when a task is big, ambiguous, high-risk, or spans multiple files and you want a disciplined plan → decompose → delegate → review flow instead of diving straight into edits. It enforces the harness's orchestration doctrine and review gates so nothing ships unverified.

Task: **$ARGUMENTS**

## Usage

`/gated-orchestration <task description>` — e.g. `/gated-orchestration migrate the auth module to the new session API`.

## Parameters

- `$ARGUMENTS` (required) — the task or goal in one or two sentences. If empty, ask for it before proceeding.

## Preconditions

- Repo state is understood (`git status`); you are on a feature branch or worktree, not the default branch.
- The relevant context has been read: [`AGENTS.md`](../../AGENTS.md), [`../../.agents/workflows/orchestration.md`](../../.agents/workflows/orchestration.md).

## Procedure

1. **Frame.** Restate the task, the user-visible outcome, and the constraints. Surface unknowns; if a decision is irreversible/outward-facing with no safe default, stop and ask.
2. **Plan (gate 1).** Write a sprint contract in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md) using the planning workflow: goal, scope, non-goals, acceptance criteria, verification plan, risk level, model tier.
3. **Choose the mode.** Apply the decision matrix in [`../../.agents/workflows/orchestration.md`](../../.agents/workflows/orchestration.md): single agent → subagent → dynamic workflow → agent team. Default to the lightest mode that works. Justify the choice in [`../../.agents/logs/orchestration.md`](../../.agents/logs/orchestration.md).
4. **Decompose.** Break the work into the smallest independently-verifiable units. Mark each parallel-safe or sequential per the parallelization assessment.
5. **Delegate & implement.** Execute units in the chosen mode. Each implementer verifies its own work (lint/typecheck/tests/build as applicable) before reporting back.
6. **Review (gate 2).** Run a strict review via `/review-10x` (skill: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)). Fix Critical and Major issues. Iterate up to the loop cap.
7. **Integrate & verify (gate 3).** Merge units, resolve conflicts, run full verification, confirm no secrets/attribution, update logs and `feature_list.json`.
8. **Hand off.** Produce a compact handover via `/final-handoff`.

## Stop Conditions

- **Success:** acceptance criteria met, review verdict `PASS` at 10/10, verification evidence captured, logs updated.
- **Escalate / stop and ask:** an irreversible or outward-facing action with no safe default; a blocker that can't be resolved in-session; review cannot reach PASS within the loop cap (document remaining issues and create follow-ups).
- Never loop indefinitely — respect the iteration caps in [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

- Confirm before destructive or outward-facing actions (deletes, force-push, migrations, publishing, sending messages).
- Never weaken auth, validation, or rate limits to make a task pass; never commit or echo secrets.
- No AI/LLM attribution in any commit, PR, doc, or comment.
- Do not force parallelism — sequential when work shares files, contracts, or migrations.

## Output

Emit an orchestration report:

```md
## Orchestration — <task>
- Mode: <single agent | subagent | dynamic workflow | agent team> — <why>
- Plan: <sprint-contract link>
- Units: <list, parallel-safe vs sequential>
- Verification: <commands + results>
- Review: Score X/10 — Verdict PASS|REVISE|BLOCK
- Follow-ups: <issues/notes>
- Handover: <link>
```

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md), [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`orchestration.md`](../../.agents/workflows/orchestration.md), [`planning.md`](../../.agents/workflows/planning.md), [`agent-teams.md`](../../.agents/workflows/agent-teams.md), [`dynamic-workflows.md`](../../.agents/workflows/dynamic-workflows.md)
- **Commands:** `/review-10x`, `/build-loop`, `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
