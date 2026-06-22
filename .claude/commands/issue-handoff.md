---
description: Write a handoff note onto an issue for the next session
argument-hint: "[issue-number]"
---

# /issue-handoff

> Capture the current state, next best actions, and risks for an issue so the next session can resume without rediscovery.

## Purpose

Use this at the end of any session where work on a GitHub issue is paused, blocked, or handed off. Posts a structured handoff comment directly to the issue (when `gh` is available) so the next agent or engineer can orient immediately.

Issue: **$ARGUMENTS**

## Usage

`/issue-handoff <issue-number>` — e.g. `/issue-handoff 42`.

If no issue number is provided, infer from the current branch name or active sprint contract; otherwise ask.

## Preconditions

- Working tree understood: `git status` run, active branch known.
- Issue exists and is accessible (`gh` authenticated or issue number known for local-only output).
- Sprint contract or progress log for this issue is current in [`.agents/logs/progress.md`](../../.agents/logs/progress.md).

## Procedure

Gather current state (done / in-progress / blocked / key files / evidence), write the handoff note per the handover format, post as an issue comment via `gh` (or print to stdout), append to the in-repo handover log. Full format: [`.agents/workflows/handover.md`](../../.agents/workflows/handover.md).

## Stop Conditions

Success: handoff note written, posted or printed, log updated. Stop and ask: issue number cannot be determined; `gh` post fails ambiguously; issue is closed and handoff is unclear.

## Safety

Never commit or echo secrets in the handoff note. Do not post to closed issues without confirming first. Do not post the same handoff twice — check recent comments before posting.

## Output

Emits a Handoff note (state: done/in-progress/blocked, next best actions, important files, risks, evidence) posted as an issue comment or printed to stdout if `gh` is unavailable; appended to [`.agents/logs/handover.md`](../../.agents/logs/handover.md). Handover format: [`.agents/workflows/handover.md`](../../.agents/workflows/handover.md). Issue workflow: [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).

## Related

- **Skills:** [`handoff-writing`](../../.claude/skills/handoff-writing/SKILL.md), [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md)
- **Workflows:** [`handover.md`](../../.agents/workflows/handover.md), [`github-issues.md`](../../.agents/workflows/github-issues.md)
- **Commands:** `/issue-loop`, `/issue-plan`, `/issue-breakdown`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
