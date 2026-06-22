---
description: Work a set of issues one at a time, each via build-loop (max 6)
argument-hint: "[issue-numbers]"
---

# /issue-loop

> Clear a queue of issues, resolving each through its own bounded build-loop, one at a time.

## Purpose

Use this when you have a batch of GitHub issues to work through sequentially. Each issue gets its own `/build-loop` run (up to 6 iterations), keeping work focused and context clean. Stops when the queue is empty, **6 issues** are done, or a decision-gate blocker is hit.

Issues: **$ARGUMENTS**

## Usage

`/issue-loop <issue-numbers>` — e.g. `/issue-loop 12 15 18 22`.

Omit arguments to resume from the queue in [`.agents/logs/progress.md`](../../.agents/logs/progress.md).

## Preconditions

- `gh auth status` passes; the repo is accessible via `gh issue view`.
- On a feature branch or worktree, not the default branch.
- [`AGENTS.md`](../../AGENTS.md) and [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md) have been read this session.
- No other `/build-loop` or `/issue-loop` run is in progress.

## Procedure

Build the queue, gate each issue for workability, delegate to `/build-loop`, update issue state on PASS, advance. Full procedure: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) + [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).

## Stop Conditions

Queue empty; 6 issues processed; decision gate hit; 3+ consecutive blocked/skipped issues. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Never close an issue without verification evidence. Every skip must be logged with a reason. Approval from one issue does not carry to the next.

## Output

Emits a run summary table (issue, score, verdict, notes) and remaining queue. Schema, stop conditions (blocker cascade, cap), safety rules: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Issue workflow: [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).

## Related

- **Skills:** [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md), [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`github-issues.md`](../../.agents/workflows/github-issues.md)
- **Commands:** `/build-loop`, `/issue-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
