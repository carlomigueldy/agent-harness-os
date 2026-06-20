---
description: Break an epic into scoped, parallel-aware sub-issues
argument-hint: "[epic-number-or-description]"
---

# /issue-breakdown

> Decompose an epic into the smallest independently-verifiable sub-issues, each with acceptance criteria, a parallel-safe assessment, and dependencies.

## Purpose

Use this when an epic or large goal needs to be split into concrete, actionable work items before implementation begins. It produces a ready-to-file sub-issue list with explicit dependency ordering and parallelism metadata so agents and humans can pick up tasks without ambiguity.

Epic: **$ARGUMENTS**

## Usage

`/issue-breakdown <epic-number-or-description>` — e.g. `/issue-breakdown #42` or `/issue-breakdown "add multi-tenant billing support"`.

## Parameters

- `$ARGUMENTS` (required) — the GitHub issue number (e.g. `#42`) or a plain description of the epic. If empty, ask before proceeding.

## Preconditions

- You have read access to the repository and, if `$ARGUMENTS` is an issue number, can fetch the issue body via `gh issue view`.
- The relevant context has been read: [`AGENTS.md`](../../AGENTS.md), [`github-issues.md`](../../.agents/workflows/github-issues.md).
- `feature_list.json` exists at the repo root (read it to cross-reference IDs).

## Procedure

1. **Read the epic.** If `$ARGUMENTS` is an issue number, run `gh issue view $ARGUMENTS` to retrieve the full title, description, goals, and non-goals. If `$ARGUMENTS` is a description, treat it as the epic definition. Surface any ambiguities — scope gaps, missing acceptance criteria, unclear non-goals — before proceeding. Do not guess at intent for irreversible scope decisions; ask.

2. **Split into the smallest independently-verifiable units.** For each unit the following must be true: it can be implemented, tested, and reviewed in isolation; its completion can be verified without depending on unmerged sibling work. Merge units only when coupling is unavoidable (shared migration, shared contract). Aim for granularity that maps to a single PR.

3. **For each unit, record all of the following:**
   - **Title** — concise, verb-led (e.g. "Add rate-limit middleware to `/api/auth`").
   - **Acceptance criteria** — a bulleted list of concrete, verifiable conditions. Each criterion must be falsifiable (a test or observation can prove it true or false).
   - **Parallel-safe** — `yes` if this unit can be worked concurrently with others (no shared files, migrations, or contracts in flight); `no` with a brief reason if sequential.
   - **Dependencies** — list any sub-issues that must be merged before this one can start. Use tentative numbering (Sub-1, Sub-2, …) if GitHub issues have not been created yet.
   - **Suggested labels** — from the project's label set (e.g. `type: feature`, `type: chore`, `area: {{AREA}}`, `priority: {{P0|P1|P2}}`).

4. **Map units to `feature_list.json`.** Read `feature_list.json`. For each sub-issue, record the matching `id` if one exists, or note `"no match"`. If a sub-issue represents work not yet in `feature_list.json`, flag it as a candidate for addition but do not modify the file without confirmation.

5. **Emit the sub-issue list and a dependency/execution order.** Output the full breakdown (see Output format below) and a dependency graph expressed as an ordered execution plan: list parallel batches (units that can run concurrently) separated from sequential gates (units that must complete before the next batch begins).

## Stop Conditions

- **Success:** all units are listed, each has acceptance criteria, parallel-safe status, and dependency mapping; the execution order is unambiguous.
- **Stop and ask:** the epic description is missing critical scope or acceptance criteria that cannot be inferred; a unit's boundary is genuinely ambiguous and the wrong split would waste significant work.
- **Do not proceed to implementation** — this command produces a plan only. Execution happens via `gh issue create` (manually or via `/issue-loop`) after the plan is confirmed.

## Safety

- Do not create GitHub issues automatically. Output the plan for review first; issue creation is a separate step.
- No AI/LLM attribution in any issue title, body, or label.
- Never echo secrets or environment variable values in issue bodies.
- Do not modify `feature_list.json` without explicit confirmation.

## Output

Emit the breakdown in this format:

```md
## Epic Breakdown — <epic title or description>

### Sub-issues

| # | Title | Parallel-safe | Depends on | Labels | feature_list.json id |
|---|-------|--------------|------------|--------|----------------------|
| Sub-1 | ... | yes | — | ... | ... |
| Sub-2 | ... | no (shares migration) | Sub-1 | ... | ... |

### Acceptance Criteria

**Sub-1 — <title>**
- [ ] <criterion>
- [ ] <criterion>

**Sub-2 — <title>**
- [ ] <criterion>

### Execution Order

**Batch 1 (parallel):** Sub-1, Sub-3
**Gate:** Sub-2 (requires Sub-1 merged)
**Batch 2 (parallel):** Sub-4, Sub-5

### Notes
- <any flags for feature_list.json additions, scope gaps, or follow-up decisions>
```

## Related

- **Skills:** `github-issue-planning`
- **Workflows:** [`github-issues.md`](../../.agents/workflows/github-issues.md), [`planning.md`](../../.agents/workflows/planning.md), [`orchestration.md`](../../.agents/workflows/orchestration.md)
- **Commands:** `/issue-plan`, `/issue-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
