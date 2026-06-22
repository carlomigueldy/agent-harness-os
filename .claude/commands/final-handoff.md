---
description: Produce the compact end-of-session handover plus clean-state check
---

# /final-handoff

> Write the compact end-of-session handover and run the clean-state checklist so the next session resumes without rediscovery.

## Purpose

Use this at the end of any session that made meaningful progress, got blocked, or changed the project state. Runs the clean-state gate first, then writes a minimal handover answering exactly what the next session needs to know.

## Usage

`/final-handoff` — takes no arguments. Invoke after verification passes and before ending the session.

## Preconditions

- Verification for the current task has been run and evidence is captured.
- Not mid-iteration of a loop command; complete or stop the loop first.
- Verification commands confirmed from [`.agents/context/commands.md`](../../.agents/context/commands.md).

## Procedure

Run the clean-state checklist, write the compact handover, update `session-handoff.md` and the handover log, confirm the next best action is unambiguous. Full procedure: [`.agents/workflows/handover.md`](../../.agents/workflows/handover.md).

## Stop Conditions

Success: clean-state check passed, both files updated, next best action specific and unambiguous. Stop and resolve: staged secrets, unresolved conflicts, or an active loop not cleanly stopped.

## Safety

Never commit or echo `.env`, secrets, or API keys. Do not list secret values in the handover — reference that a secret exists and where it is configured. If the next step is destructive/outward-facing, record that it needs explicit approval.

## Output

Emits a Handover Block written to both `../../session-handoff.md` (replaces previous entry) and [`.agents/logs/handover.md`](../../.agents/logs/handover.md) (appended). Handover format, clean-state checklist, and procedure: [`.agents/workflows/handover.md`](../../.agents/workflows/handover.md). Skill: [`handoff-writing`](../../.claude/skills/handoff-writing/SKILL.md).

## Related

- **Skills:** [`handoff-writing`](../../.claude/skills/handoff-writing/SKILL.md)
- **Workflows:** [`handover.md`](../../.agents/workflows/handover.md)
- **Commands:** `/release-check`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
