---
description: Break an epic into scoped, parallel-aware sub-issues
argument-hint: "[epic-number-or-description]"
---

# /issue-breakdown

> Decompose an epic into the smallest independently-verifiable sub-issues, each with acceptance criteria, a parallel-safe assessment, and dependencies.

## Purpose

Use this when an epic or large goal needs to be split into concrete, actionable work items before implementation begins. Produces a ready-to-file sub-issue list with explicit dependency ordering and parallelism metadata. Does not create issues automatically — emits a plan for review first.

Epic: **$ARGUMENTS**

## Usage

`/issue-breakdown <epic-number-or-description>` — e.g. `/issue-breakdown #42` or `/issue-breakdown "add multi-tenant billing support"`.

If `$ARGUMENTS` is empty, ask before proceeding.

## Preconditions

- Read access to the repo; if `$ARGUMENTS` is an issue number, `gh issue view` is available.
- Read: [`AGENTS.md`](../../AGENTS.md), [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).
- `feature_list.json` exists at the repo root.

## Procedure

Read the epic, split into the smallest independently-verifiable units, record acceptance criteria / parallel-safe / dependencies for each, map to `feature_list.json`, emit breakdown with execution order. Full rules: [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md) + [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).

## Stop Conditions

Success: all units listed with acceptance criteria, parallel-safe status, and dependency mapping; execution order unambiguous. Stop and ask: epic description missing critical scope that cannot be inferred. Do not proceed to implementation — this command produces a plan only.

## Safety

Do not create GitHub issues automatically — output the plan first; issue creation is a separate step. Never modify `feature_list.json` without explicit confirmation.

## Output

Emits an Epic Breakdown (sub-issue table with parallel-safe/depends-on/labels/feature-list-id, acceptance criteria per sub-issue, execution order). Full sub-issue decomposition rules and label taxonomy: [`.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md). Skill: [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md).

## Related

- **Skills:** [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md)
- **Workflows:** [`github-issues.md`](../../.agents/workflows/github-issues.md), [`planning.md`](../../.agents/workflows/planning.md)
- **Commands:** `/issue-plan`, `/issue-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
