---
description: Scan recent work for repeated workflows; propose or create skills (max 3)
---

# /skill-evolution-loop

> Find repeated workflows in recent session history and propose or create reusable skills from them.

## Purpose

Use this after one or more sessions of active development to surface patterns worth encoding as durable skills or commands. It keeps the harness evolving in step with how real work is actually done — without accumulating duplicate or low-value artifacts.

Run it periodically (e.g. at the end of a sprint or epic) or whenever you notice yourself repeating the same multi-step workflow across sessions.

## Usage

`/skill-evolution-loop` — no arguments; the command scans the session record and logs autonomously.

## Parameters

None. The command operates on the existing logs and history in the current repo.

## Preconditions

- At least one session log or handover entry exists in [`.agents/logs/`](../../.agents/logs/) or [`session-handoff.md`](../../session-handoff.md).
- You have read access to [`.claude/skills/`](../../.claude/skills/) to check for existing skills before proposing new ones.

## Procedure

1. **Gather evidence.** Read recent session logs (`claude-progress.md`, `.agents/logs/progress.md`, `.agents/logs/handover.md`, `session-handoff.md`). Identify every multi-step task that was performed more than once — across sessions or within a single session by repetition. List them with: what the task does, how many steps it involves, and how many times it appeared.

2. **Score each candidate.** For each repeated task, evaluate on three axes:
   - **Reuse value** — would encoding this save meaningful effort in future sessions?
   - **Generality** — is it stack-agnostic or easily parameterised, not tied to one ad-hoc situation?
   - **Novelty** — is it absent from the existing skill index ([`.claude/skills/`](../../.claude/skills/)) and command list ([`.claude/commands/`](../../.claude/commands/))?
   Discard any candidate that fails any axis. Keep only candidates that pass all three.

3. **Rank and cap.** Sort survivors by combined score (reuse × generality × novelty). Take the top three at most. If fewer than three pass, proceed with what you have. If none pass, record a dry-round observation (no qualifying patterns found) and increment the dry-round counter.

4. **Decide: propose or create.** For each kept candidate:
   - If the workflow is well-understood and clearly ready to codify: create the skill immediately by running `/create-skill` (which drives the `skill-authoring` procedure). Follow the SKILL.md schema exactly.
   - If the workflow is valuable but still evolving, or its shape is uncertain: write a proposal in the `.agents/proposals/` directory using the standard proposal format — name, problem, proposed shape, alternatives, effort, recommendation. Mark it `PROPOSED, pending approval`.
   - Never create a skill or command without at least one supporting evidence entry from the log scan.

5. **Register new skills.** If you created any skills, append them to the skill index in [`.agents/context/skills.md`](../../.agents/context/skills.md) with a one-line purpose summary. If you created commands, update the table in [`.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md).

6. **Log the round.** Append a round summary to `.agents/logs/progress.md`: iteration number, candidates considered, outcomes (created / proposed / discarded), dry-round count. Update `session-handoff.md` if this run closes a session.

7. **Repeat if warranted.** If new candidates remain unconsidered and the iteration cap has not been reached, run another iteration from step 1 using the updated skill index as the baseline for novelty checks.

## Stop Conditions

- **Success:** all surviving candidates have been either created or formally proposed; outcomes logged; indexes updated.
- **Dry-round stop:** two consecutive iterations with zero qualifying candidates → record the observation and stop. Do not manufacture candidates to fill a quota.
- **Iteration cap:** stop after **3 iterations** regardless of remaining candidates. Document any untreated candidates in `.agents/logs/progress.md` as deferred.
- Never loop past the cap — respect the bounds defined in [autonomous-loops.md](../../.agents/workflows/autonomous-loops.md).

## Safety

- Do not create skills or commands without log evidence of real recurrence. One-off tasks are not candidates.
- No AI/LLM attribution in any skill, command, commit, or proposal file.
- Never echo or embed secret values in skill templates.
- Proposals require approval before being acted on if they touch global harness config or shared workflow docs.
- Do not modify existing skills or commands without reading them first and confirming the change is an improvement, not a conflict.

## Output

Emit a skill-evolution report at the end of each iteration:

```md
## Skill Evolution — Iteration N

**Log scan range:** <date range or session IDs reviewed>

**Candidates considered:**
| Workflow | Recurrences | Reuse | Generality | Novelty | Decision |
|---|---|---|---|---|---|
| <name> | <N> | high/med/low | high/med/low | yes/no | created / proposed / discarded |

**Created skills:** <names, or "none">
**Proposals filed:** <names, or "none">
**Dry rounds so far:** <N>

**Next action:** <continue to iteration N+1 / stop — cap reached / stop — 2 dry rounds>
```

## Related

- **Skills:** [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md) — run `/create-skill` to drive it
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md)
- **Commands:** `/create-skill`, `/create-command`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
