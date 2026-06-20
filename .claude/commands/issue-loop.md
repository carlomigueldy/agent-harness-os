---
description: Work a set of issues one at a time, each via build-loop (max 6)
argument-hint: "[issue-numbers]"
---

# /issue-loop

> Clear a queue of issues, resolving each through its own bounded build-loop, one at a time.

## Purpose

Use this when you have a batch of GitHub issues to work through sequentially and want each one resolved, verified, and logged before moving to the next. Each issue gets its own `/build-loop` run (up to 6 iterations), keeping the work focused and the context clean. The command stops automatically when the queue is empty, 6 issues are done, or it encounters a blocker requiring a decision.

Issues: **$ARGUMENTS**

## Usage

`/issue-loop <issue-numbers>` — e.g. `/issue-loop 12 15 18 22`.

Omit arguments to resume from the queue recorded in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md).

## Parameters

- `$ARGUMENTS` (optional) — space-separated issue numbers. If omitted, read the pending-issues queue from [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md). If neither is available, stop and ask.

## Preconditions

- `gh auth status` passes; the repo is accessible via `gh issue view`.
- You are on a feature branch or worktree, not the default branch.
- [`../../AGENTS.md`](../../AGENTS.md) and [`../../.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md) have been read this session.
- No other `/build-loop` or `/issue-loop` run is in progress.

## Procedure

1. **Build the queue.** Parse $ARGUMENTS into an ordered list of issue numbers. If $ARGUMENTS is empty, read the pending-issues queue from [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md). Log the queue at the top of the session entry. Cap the run at 6 issues total.

2. **Take the next issue.** Pop the first issue from the queue. Run `gh issue view <number>` to fetch its title, body, labels, and acceptance criteria. If the issue is closed, skip it silently and move to the next.

3. **Gate: decide if the issue is workable.** Check for blockers before starting work:
   - Missing or ambiguous acceptance criteria with no safe default → skip, post a clarifying comment via `gh issue comment`, note the skip reason in the log.
   - Depends on an unresolved issue or out-of-scope change → skip, note the dependency in the log.
   - Needs an irreversible or outward-facing decision (migration, publish, force-push) → stop the loop, surface the decision.
   If workable, proceed.

4. **Resolve via build-loop.** Invoke `/build-loop` with the issue title and acceptance criteria as the goal. Let it run its full bounded loop (max 6 iterations). Collect the final verdict (`PASS` / `REVISE` / `BLOCK`) and score.

5. **Verify.** Confirm that the acceptance criteria are met by running the verification commands from [`../../.agents/context/commands.md`](../../.agents/context/commands.md) that match the change type (lint, typecheck, tests, build, smoke test as applicable). If `/build-loop` already captured evidence, reference it; do not re-run unnecessarily.

6. **Update the issue and logs.** On `PASS`:
   - Comment on the issue with a compact resolution note: what was changed, verification evidence, PR or commit reference.
   - Close the issue via `gh issue close <number> --comment "<resolution note>"`.
   - Append a one-line entry to [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md): issue number, title, verdict, score, timestamp.
   On `BLOCK` or unresolvable `REVISE`: leave the issue open, post a blocking note, record the issue as blocked in the log, and continue to the next issue in the queue.

7. **Advance.** Return to step 2 with the updated queue. Continue until the queue is empty, 6 issues are done, or a stop condition is hit.

8. **Emit the run summary** (see Output). If any issues were skipped or blocked, call `/issue-handoff` to record a handoff note on each one.

## Stop Conditions

- **Success:** queue is empty and all workable issues reached `PASS` with verification evidence.
- **Cap reached:** 6 issues processed (pass or block) — stop, emit the summary, leave remaining issues in the log queue for the next session.
- **Decision gate:** an issue requires an irreversible/outward-facing action with no safe default — stop the full loop, surface the decision, do not continue to the next issue until resolved.
- **Blocker cascade:** if three or more consecutive issues are blocked or skipped, stop the loop, emit the summary, and flag the pattern for triage.
- Never loop indefinitely — respect the iteration caps in [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

- Never commit or echo secrets; no AI/LLM attribution in any commit, comment, or PR.
- Confirm before destructive actions: migrations, force-push, publish, delete. Approval from one issue does not carry to the next.
- Do not close an issue until verification evidence is captured.
- Do not skip issues silently — every skip must be logged with a reason.
- A blocked `/build-loop` verdict does not automatically close or skip the issue; record it as blocked.

## Output

Emit a run summary after the loop ends:

```md
## Issue Loop — <date>
Queue: [<issue-numbers>]
Processed: <n> / 6

| # | Title | Score | Verdict | Notes |
|---|-------|-------|---------|-------|
| 12 | ... | 10/10 | PASS | PR #34 |
| 15 | ... | — | SKIPPED | needs decision: ... |
| 18 | ... | 7/10 | BLOCKED | depends on #14 |

Remaining queue: [<issue-numbers-left>]
Next action: <resume next session | decision needed: ... | none>
```

## Related

- **Skills:** `github-issue-planning`, `autonomous-loop-design`
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`github-issues.md`](../../.agents/workflows/github-issues.md)
- **Commands:** `/build-loop`, `/issue-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
