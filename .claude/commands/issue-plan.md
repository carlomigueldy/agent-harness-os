---
description: Turn a goal into an epic plus labeled sub-issue plan with acceptance criteria
argument-hint: "[goal]"
---

# /issue-plan

> Convert a goal into a structured GitHub issue plan: one epic and its sub-issues, each with acceptance criteria and labels.

## Purpose

Use this when you have a goal or feature intent and need to translate it into a fully structured GitHub issue plan before work begins. Produces an epic plus the smallest set of scoped sub-issues covering the goal. Issues are only created in GitHub if `gh` is available and the user explicitly approves.

Goal: **$ARGUMENTS**

## Usage

`/issue-plan <goal>` — e.g. `/issue-plan add rate limiting to the public API`.

If `$ARGUMENTS` is empty, ask before proceeding.

## Preconditions

- The goal is clear enough to scope. If ambiguous, ask one targeted clarifying question first.
- Read [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md) for required fields and label taxonomy.
- `feature_list.json` checked for existing related features (avoid duplicate epics).

## Procedure

Read the issue workflow and label taxonomy, draft the epic (goals/non-goals/scope/AC/risks), derive sub-issues, assign labels, gate on approval, then create issues if `gh` is available and approved. Full procedure: [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md) + [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).

## Stop Conditions

Success (plan only): plan emitted and reviewed. Success (issues created): all issues exist in GitHub and `feature_list.json` is updated. Stop and ask: goal too ambiguous to scope; BLOCK if `gh` auth fails and user wants issues created.

## Safety

Never create GitHub issues without explicit user approval — issue creation is an outward-facing action. Never modify `feature_list.json` unless issues were successfully created.

## Output

Emits an Issue Plan (epic body with goals/non-goals/scope/AC/risks, sub-issues with labels/dependencies/parallel-safe/verification commands). Issues created only after explicit approval. Full field requirements, label taxonomy, and creation procedure: [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md). Skill: [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md).

## Related

- **Skills:** [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md)
- **Workflows:** [`github-issues.md`](../../.agents/workflows/github-issues.md), [`planning.md`](../../.agents/workflows/planning.md)
- **Commands:** `/issue-breakdown`, `/issue-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
