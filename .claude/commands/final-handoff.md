---
description: Produce the compact end-of-session handover plus clean-state check
---

# /final-handoff

> Write the compact end-of-session handover and run the clean-state checklist so the next session resumes without rediscovery.

## Purpose

Use this at the end of any session that made meaningful progress, got blocked, or changed the project state. It runs a clean-state gate first — no staged secrets, no uncommitted drift, logs current — then writes a minimal handover that answers exactly what the next session needs to know and nothing it can rediscover itself.

## Usage

`/final-handoff` — takes no arguments. Invoke after verification passes and before ending the session.

## Parameters

None.

## Preconditions

- Verification for the current task has been run and evidence is captured.
- You are not mid-iteration of a loop command; complete or stop the loop before invoking this.
- [`../../.agents/context/commands.md`](../../.agents/context/commands.md) has been consulted to confirm which verification commands apply to this project.

## Procedure

1. **Run the clean-state checklist.** Execute `git status` and confirm: (a) no unintended untracked or modified files, (b) no `.env`, secrets, or credential files are staged or committed, (c) any staged changes are intentional and match the task scope, and (d) [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md) reflects the actual state of the session. If anything is out of place, resolve it before continuing — do not hand off dirty state.

2. **Write the compact handover.** Following the format in [`../../.agents/workflows/handover.md`](../../.agents/workflows/handover.md), produce a handover that covers: what was done and what evidence confirms it, what is in progress and where it stands, any blockers or open decisions, the next best action the following session should take, and any gotchas that cannot be rediscovered from the repo itself. Keep it dense and actionable — no padding, no session diary.

3. **Update `session-handoff.md` and the handover log.** Write the handover to `../../session-handoff.md` (replace the previous entry — this file holds the single latest handoff). Append the same handover as a dated entry to [`../../.agents/logs/handover.md`](../../.agents/logs/handover.md) so the history is preserved. Also update `../../claude-progress.md` if the snapshot has drifted from the current state.

4. **Confirm the next best action is unambiguous.** Re-read the handover and verify the "next best action" field is specific enough for a fresh session to start without asking questions. If it is vague — e.g. "continue the feature" with no pointer to a file, branch, or task — make it precise before saving. If an outward-facing or irreversible decision is the next step (e.g. merge, publish, migrate), note that explicit approval is required before proceeding.

## Stop Conditions

- **Success:** clean-state checklist passed, both `session-handoff.md` and `../../.agents/logs/handover.md` updated, next best action is specific and unambiguous.
- **Stop and resolve first:** staged secrets or env files found, unresolved merge conflicts, or an active loop that has not been stopped cleanly — fix these before writing the handover.
- Never write a handover that claims work is done without verification evidence; evidence before claims applies here.

## Safety

- Never commit or echo `.env`, secrets, API keys, or credential files. If any are staged, unstage them and warn before continuing.
- No AI/LLM attribution in the handover text, commit messages, or any linked issue.
- Do not list secret values in the handover — reference that a secret exists and where it is configured, never its value.
- If the next step requires a destructive or outward-facing action, record that it needs explicit approval; do not pre-authorize it in the handover.

## Output

Emit a Handover Block at the end of the run and write it to both destinations:

```md
## Handover — {{SESSION_DATE}}

**Branch / worktree:** <branch and worktree path>
**Status:** COMPLETE | IN_PROGRESS | BLOCKED

### Done this session
- <concise bullet per meaningful change, with file or PR reference>

### In progress
- <task name> — <where it stands, what is left>

### Blockers / open decisions
- <blocker or decision> — <what is needed to unblock>

### Next best action
<single specific action the next session should take first — file, branch, command, or issue link>

### Gotchas
- <anything the next session cannot easily rediscover from the repo>
```

## Related

- **Skills:** `handoff-writing`
- **Workflows:** [`handover.md`](../../.agents/workflows/handover.md)
- **Commands:** `/release-check`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
