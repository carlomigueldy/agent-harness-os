---
name: github-issue-planning
description: Turn goals into epics and labeled sub-issues with acceptance criteria, parallel-safety, and dependencies
---

# Skill: github-issue-planning

## Purpose

Convert a stated goal or body of work into a clean, executable GitHub issue plan: one epic issue that scopes the initiative, and a minimal set of sub-issues that decompose it. Each sub-issue carries acceptance criteria, a parallel-safety assessment, explicit dependencies, and a label set. The output is an ordered execution plan ready to drive implementation — not an unstructured brain-dump.

## When to Use

- Planning a new feature, refactor, or initiative before writing any code.
- Breaking an existing epic into trackable sub-issues with clear ownership and sequence.
- Any time a milestone is large enough that ad-hoc implementation would create coordination risk or missed scope.
- Before running `/issue-loop` or `/issue-handoff` — this skill generates the issues they consume.

## When Not to Use

- A trivial one-liner fix that needs no tracking — open the PR directly.
- The maintainer has explicitly said not to create GitHub issues for this project; use in-repo state files (e.g. `feature_list.json`, `.agents/logs/progress.md`) instead.
- The goal is still too ambiguous to decompose — clarify scope first, then invoke this skill.

## Inputs

- A goal statement or feature brief (plain language is fine).
- Access to the label taxonomy for the repository (check the GitHub repo's label list or the workflow doc).
- Optional: an existing epic issue number to nest sub-issues under.
- Optional: `gh` CLI authenticated and targeting the correct remote (`gh auth status`, `gh repo view`).

## Outputs

- A drafted **epic issue**: title, body with goal summary, scope boundaries, and links to sub-issues.
- A set of **sub-issues**, each with:
  - Title and one-paragraph body
  - Acceptance criteria (bulleted, verifiable, testable)
  - `parallel_safe: true/false` with brief rationale
  - `depends_on: [#N, ...]` (empty if none)
  - Labels from the project taxonomy
- An **execution order**: a numbered sequence (or parallel groups) derived from the dependency graph.
- Issues are created on the remote only when a remote exists, `gh` is authenticated, and the plan has been approved.

## Procedure

1. **Read the github-issues workflow.** Open [`../../../.agents/workflows/github-issues.md`](../../../.agents/workflows/github-issues.md) and note the label taxonomy, issue body conventions, and any project-specific rules. If the workflow file does not exist, fall back to the project's own issue conventions or GitHub defaults.

2. **Draft the epic.** Write an epic issue that captures:
   - The goal in one sentence (the "why").
   - Scope: what is in and explicitly what is out.
   - Success criteria at the epic level.
   - A placeholder checklist for sub-issue links (fill after step 3).
   Do not create the epic on the remote yet.

3. **Decompose into the minimal set of sub-issues.** For each sub-issue:
   - Give it a precise, action-oriented title (verb + noun: "Add rate-limit middleware", not "Rate limiting").
   - Write a one-paragraph body: context, what needs to change, and why.
   - List acceptance criteria as a bulleted checklist — every item must be independently verifiable (passing test, visible behavior, metric). Avoid vague criteria like "works correctly."
   - Assess `parallel_safe`: can this run concurrently with other open sub-issues, or does it share mutable state, schema, or config that requires serialization? State the reason.
   - List `depends_on` by sub-issue index (to be replaced with `#N` after creation).
   - Assign labels: at minimum a type label (`feat`, `fix`, `refactor`, `docs`, `chore`) and a scope label matching the affected area.

4. **Define execution order.** Build a dependency graph from the `depends_on` fields. Identify:
   - Issues with no dependencies → Group A (can start immediately, in parallel if `parallel_safe: true`).
   - Issues blocked by Group A → Group B, and so on.
   Emit the plan as ordered groups, each listing the issues that can run in that phase and whether they are parallel-safe within the group.

5. **Emit the plan and gate on approval before creating.** Present the full plan as structured Markdown (epic draft + sub-issue drafts + execution order). Do not call `gh issue create` until:
   - A remote repository is confirmed (`gh repo view` succeeds).
   - The plan has been reviewed and approved (by the maintainer or, in an autonomous loop, the review gate).
   When approved, create the epic first, then sub-issues in dependency order, updating each body with real `#N` cross-links as issues are created. Pin the epic to the repo if permissions allow. After creation, update the epic's checklist with the real sub-issue numbers.

## Checks

- Every acceptance criterion is independently verifiable — no criterion reads "should work" or "looks good."
- Every sub-issue that touches shared state (DB schema, config, auth, CI pipeline) is marked `parallel_safe: false`.
- The dependency graph is acyclic — no circular `depends_on` chains.
- All labels used exist in the repository's label taxonomy (or have been noted as needing creation).
- No secrets, tokens, or environment values appear in any issue body.
- No AI/LLM attribution in issue titles, bodies, or comments.
- Issues are not created on the remote before the plan is approved.

## Common Failure Modes

- **Over-decomposition** — creating 20 sub-issues for a two-day effort. Keep sub-issues at the PR-size level: each should map to one focused, reviewable change.
- **Vague acceptance criteria** — writing "feature works as expected." Every criterion must have a concrete, binary pass/fail signal.
- **Missing dependency edges** — marking everything `parallel_safe: true` when shared schema or config makes concurrent work unsafe. Check for shared migrations, environment variables, or interface contracts.
- **Creating issues before plan approval** — opening issues on the remote makes them visible to collaborators and hard to cleanly retract. Always gate on approval.
- **Label mismatch** — using labels that don't exist in the repo, causing issues to have no labels applied. Verify the taxonomy first.
- **Skipping the epic** — jumping straight to sub-issues leaves no single artifact that tracks the full initiative and its completion state.

## Example Usage

> Goal: "Add user notification preferences — email and in-app toggles, stored per user, respected by the notification dispatch service."
>
> 1. Read `github-issues.md` → label taxonomy: `feat`, `fix`, `backend`, `frontend`, `db`.
> 2. Draft epic: "feat: User notification preferences" — scope covers preference storage, UI toggles, and dispatch integration; out of scope: push notifications.
> 3. Sub-issues drafted:
>    - `feat(db): Add notification_preferences table migration` — `parallel_safe: false` (schema change), no deps.
>    - `feat(backend): Notification preferences API (CRUD)` — `parallel_safe: false` (depends on migration), `depends_on: [#1]`.
>    - `feat(frontend): Notification preferences settings page` — `parallel_safe: true`, `depends_on: [#2]`.
>    - `feat(backend): Respect preferences in dispatch service` — `parallel_safe: false`, `depends_on: [#2]`.
> 4. Execution order: Group A → migration; Group B → API; Group C → settings page + dispatch (parallel within group).
> 5. Plan presented; approved; epic created as `#10`; sub-issues created as `#11–#14`; epic checklist updated.

Pair this output with `/issue-handoff` to write a compact session handover that references the created issues.

## Related Commands

`/issue-plan`, `/issue-breakdown`, `/issue-handoff`

## Maintenance Notes

- When the label taxonomy changes, update step 1 and the Checks section to reflect the new labels.
- If the project adopts a different issue body template (e.g. a GitHub issue form), align the sub-issue draft structure in step 3 with that template.
- When `handoff-writing` skill is scaffolded at `../handoff-writing/SKILL.md`, add a cross-link in the Example Usage section.
- Keep execution-order guidance in sync with [`../../../.agents/workflows/github-issues.md`](../../../.agents/workflows/github-issues.md) if that workflow's sequencing rules change.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
