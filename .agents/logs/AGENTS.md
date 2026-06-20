# Context: `.agents/logs/`

## Purpose

The harness's append-only running record — the system of record across sessions. A fresh session reconstructs "what happened and what's next" from here, so these files must stay honest and current.

## Important Files

| Path | What it is | Update cadence |
|---|---|---|
| [`progress.md`](progress.md) | Current phase, sprint contracts, next actions | Every session |
| [`decisions.md`](decisions.md) | Architectural/workflow decisions + rationale | When a decision is made |
| [`changelog.md`](changelog.md) | Task-by-task changelog | Every completed task |
| [`verification.md`](verification.md) | Verification evidence (commands, results, artifacts) | After verification runs |
| [`handover.md`](handover.md) | Session handover history | End of session |
| [`learnings.md`](learnings.md) | Short, searchable, actionable lessons | When something is learned |
| [`retrospectives.md`](retrospectives.md) | Per-task self-scores and verdicts | After meaningful tasks |
| [`failures.md`](failures.md) | Failure attribution (symptom, root cause, fix) | When something fails |
| [`orchestration.md`](orchestration.md) | Mode log for multi-agent runs | When orchestrating |

## How This Directory Is Used

Read [`progress.md`](progress.md) and the latest handover at session start; append to the relevant logs as work happens; update progress + write a handover before ending.

## Agent Rules

- **Append, don't rewrite history.** Add new dated entries newest-first; don't silently edit or delete past entries (correct with a new entry).
- Convert relative dates to absolute (`YYYY-MM-DD`).
- Be honest: never claim verification that didn't run or evidence that doesn't exist.
- Keep entries short, searchable, and actionable. Link to files/issues.
- No AI/LLM attribution anywhere.
- These files are tracked state — `.gitignore` explicitly never-ignores `.agents/logs/`.

## Common Workflows

- **Record a decision:** append to [`decisions.md`](decisions.md) using its format.
- **Log verification:** append commands + results to [`verification.md`](verification.md).
- **Attribute a failure:** append to [`failures.md`](failures.md); if the cause was a harness gap, propose an improvement.
- **Write a handover:** `/final-handoff` updates [`handover.md`](handover.md) and `../../session-handoff.md`.

## Commands

`/final-handoff`, `/issue-handoff`, `/release-check`. See [`../context/slash-commands.md`](../context/slash-commands.md).

## Skills

[`handoff-writing`](../../.claude/skills/handoff-writing/SKILL.md), [`release-readiness`](../../.claude/skills/release-readiness/SKILL.md).

## Testing / Validation

`bash ../../scripts/verify-harness.sh` confirms the logs dir exists with enough docs and that links resolve. Content honesty is enforced by review, not tooling.

## Known Risks

- Stale `progress.md` is the most common harness failure — a new session then guesses. Always update it.
- Rewriting log history hides what really happened; append corrections instead.

## Recent Decisions

- See [`decisions.md`](decisions.md) for the full log.

## Update Rules

Every session updates [`progress.md`](progress.md) and writes a handover. Every completed task updates [`changelog.md`](changelog.md). Meaningful decisions, failures, and learnings get their own entries the moment they occur.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
