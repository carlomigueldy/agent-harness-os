---
description: Write a handoff note onto an issue for the next session
argument-hint: "[issue-number]"
---

# /issue-handoff

> Capture the current state, next best actions, and risks for an issue so the next session can resume without rediscovery.

## Purpose

Use this command at the end of any session where work on a GitHub issue is paused, blocked, or handed off. It produces a structured handoff comment posted directly to the issue (when `gh` is available) so that the next agent or engineer can orient immediately without re-reading the full thread or diff history.

Issue: **$ARGUMENTS**

## Usage

`/issue-handoff <issue-number>` — e.g. `/issue-handoff 42`.

If no issue number is provided, infer it from the current branch name or active sprint contract; if it still cannot be determined, stop and ask.

## Parameters

- `$ARGUMENTS` (required) — the GitHub issue number to annotate. If empty, infer from branch name or sprint contract; otherwise ask before proceeding.

## Preconditions

- The working tree is understood: `git status` has been run, the active branch or worktree is known.
- The issue exists and is accessible (either `gh` is authenticated or the issue number is known for local-only output).
- The relevant sprint contract or progress log entry for this issue is current in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md).

## Procedure

1. **Gather current state.** Collect the following before writing anything:
   - What is done: completed tasks, merged or staged changes, passing checks.
   - What is in progress: partially completed work, open PRs, pending reviews.
   - What is blocked: blockers, missing inputs, decisions pending approval, failing checks, unknowns that cannot be resolved in-session.
   - Key files touched: list files changed or directly relevant to the issue.
   - Evidence: test results, lint output, build status, screenshots or links — only what actually ran.

2. **Write the handoff note** using the standard handover format from [`../../.agents/workflows/handover.md`](../../.agents/workflows/handover.md). The note must include all of these sections:

   ```md
   ## Handoff — Issue #<number>: <title>

   **Date:** <YYYY-MM-DD>
   **Branch / worktree:** <branch-name>

   ### State
   - Done: <bullet list>
   - In progress: <bullet list, or "none">
   - Blocked: <bullet list, or "none">

   ### Next best actions
   1. <Most urgent / highest-leverage action>
   2. <Next>
   3. ...

   ### Important files
   - `<path>` — <one-line note on why it matters>

   ### Risks & open questions
   - <Risk or unknown that the next session must resolve>

   ### Evidence
   - <Command run>: <result / link>
   ```

   Keep it tight. Omit sections that have no content rather than leaving them blank.

3. **Post or output the handoff.** Check whether `gh` is available and the user is authenticated:
   - If `gh` is available: run `gh issue comment <number> --body "$(cat <<'EOF' ... EOF)"` to post the note as an issue comment. Confirm the URL of the posted comment.
   - If `gh` is not available or authentication fails: print the full handoff note to stdout so it can be copy-pasted manually. Clearly state that it was not posted.
   - Never post the same handoff twice — check recent comments before posting.

4. **Update the in-repo handover log.** Append a compact entry to [`../../.agents/logs/handover.md`](../../.agents/logs/handover.md) in this format:

   ```md
   ### <YYYY-MM-DD> — Issue #<number>
   - State: <done / in-progress / blocked summary in one line>
   - Next: <top next action>
   - Comment: <gh issue URL or "not posted — gh unavailable">
   ```

   If the file does not exist, create it with a heading `# Handover Log` before appending.

## Stop Conditions

- **Success:** handoff note written, posted (or printed), and in-repo log updated.
- **Stop and ask:** issue number cannot be determined; `gh` post fails and it is unclear whether to retry or skip; the issue is closed and it is ambiguous whether a handoff comment is appropriate.
- **Do not loop** — this command runs once per invocation.

## Safety

- Never commit or echo secrets, tokens, or credentials in the handoff note.
- No AI/LLM attribution in any comment, commit message, or log entry — write as the project author.
- Do not post to closed issues without confirming with the user first.
- Do not include personally identifying information or sensitive user data in comments posted to public repositories.

## Output

Emit a brief confirmation after completing:

```md
## Handoff — Issue #<number>

- Comment: <URL of posted comment, or "not posted — gh unavailable">
- Log entry: appended to .agents/logs/handover.md
- Next action: <top item from the note>
```

## Related

- **Skills:** `handoff-writing`, `github-issue-planning`
- **Workflows:** [`handover.md`](../../.agents/workflows/handover.md), [`github-issues.md`](../../.agents/workflows/github-issues.md)
- **Commands:** `/issue-loop`, `/issue-plan`, `/issue-breakdown`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
