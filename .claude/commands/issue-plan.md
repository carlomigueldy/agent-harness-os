---
description: Turn a goal into an epic plus labeled sub-issue plan with acceptance criteria
argument-hint: "[goal]"
---

# /issue-plan

> Convert a goal into a structured GitHub issue plan: one epic and its sub-issues, each with acceptance criteria and labels.

## Purpose

Use this command when you have a goal or feature intent and need to translate it into a fully structured GitHub issue plan before work begins. It produces an epic issue plus the smallest set of scoped sub-issues that together cover the goal — each with acceptance criteria, a parallel-safe flag, dependencies, and labels from the project's taxonomy. The plan is emitted as markdown; issues are only created in GitHub if `gh` is available and the user explicitly approves.

Goal: **$ARGUMENTS**

## Usage

`/issue-plan <goal>` — e.g. `/issue-plan add rate limiting to the public API`.

## Parameters

- `$ARGUMENTS` (required) — the goal or feature intent in one or two sentences. If empty, ask for it before proceeding.

## Preconditions

- The goal is clear enough to scope. If it is ambiguous or too large to bound, ask one targeted clarifying question before drafting.
- The relevant workflow has been read: [`../../.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md).
- `feature_list.json` has been checked for existing related features (avoid duplicate epics).

## Procedure

1. **Read the issue workflow and label taxonomy.** Open [`../../.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md). Internalize the epic and sub-issue required fields and the full label set (`type:`, `priority:`, `status:`, `area:`, and modifier labels such as `parallel-safe`, `sequential-required`, `needs-verification`).

2. **Draft the epic.** Produce a complete epic body covering every required field from the workflow:
   - **Summary** — one paragraph stating the goal and the user value it delivers.
   - **Goals** — bulleted list of outcomes this epic achieves.
   - **Non-goals** — explicit scope boundary; what this epic will NOT address.
   - **Scope** — modules, layers, or services touched; rough effort estimate (S / M / L / XL).
   - **Acceptance criteria** — numbered, testable, verifiable conditions for Done.
   - **Verification plan** — commands or manual steps that confirm each criterion is met.
   - **Risks** — known unknowns; flag any dependency on external systems, migrations, or secrets.
   - **Release notes stub** — one line suitable for a changelog entry.

3. **Derive sub-issues.** Break the epic into the smallest independently-deliverable units. For each sub-issue record:
   - **Title** — verb-led, scoped (e.g. "Implement token-bucket middleware for `/api/*`").
   - **Parent epic** — reference placeholder (`#<epic>`) to be filled on creation.
   - **Acceptance criteria** — numbered, testable conditions specific to this sub-issue.
   - **Dependencies** — other sub-issues that must complete first (by title).
   - **Parallel-safe** — `yes` if it can run concurrently with sibling sub-issues, `no` if sequential.
   - **Worktree required** — `yes` / `no`.
   - **Verification command(s)** — the exact check that proves this sub-issue is done.

4. **Assign labels.** For every issue (epic and each sub-issue) assign labels from the taxonomy in [`../../.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md):
   - `type:` — one of `epic`, `task`, `bug`, `chore`, `docs`, `refactor`, `test`.
   - `priority:` — one of `critical`, `high`, `medium`, `low`.
   - `status:` — start as `status: in-progress` for the active epic; sub-issues start unlabeled for status until work begins.
   - `area:` — optional project-specific area label if the taxonomy defines one (e.g. `area: api`, `area: auth`).
   - Modifier labels as applicable: `parallel-safe`, `sequential-required`, `needs-verification`, `needs-demo`, `worktree-session`.

5. **Gate: present and get approval.** Emit the full plan as markdown (see Output). If `gh` is not authenticated (`gh auth status` fails) or the user does not approve, stop here — the markdown plan is the deliverable. Do not create issues without explicit approval.

6. **Create issues (conditional).** If `gh` is available AND the user approves:
   a. Create the epic first: `gh issue create --title "<epic title>" --body "<body>" --label "type:epic,priority:<p>"`.
   b. Capture the epic issue number from the output.
   c. Create each sub-issue in dependency order, substituting the real epic number for `#<epic>` in each parent-reference field.
   d. After each sub-issue is created, capture its issue number and add it to the epic body by editing the epic issue: `gh issue edit <epic-number> --body "<updated body with #sub-issue links>"`.
   e. Update `feature_list.json` to add or update the entry with `"github_issue": <epic-number>`.
   f. Confirm all issues are visible: `gh issue list --state open`.

## Stop Conditions

- **Success (plan only):** Plan emitted as markdown; user has reviewed it; no `gh` creation requested.
- **Success (issues created):** All issues exist in GitHub, are linked, and `feature_list.json` is updated.
- **Stop and ask:** Goal is too ambiguous to scope without a clarifying answer; or a decision affects security, migrations, or prod infra and has no safe default.
- **Block:** `gh` auth fails and user wants issues created — report the auth failure and provide the exact `gh auth login` command to unblock.

## Safety

- Never create GitHub issues without explicit user approval — issue creation is an outward-facing action.
- Do not hardcode secrets, tokens, or environment-specific values into issue bodies.
- No AI/LLM attribution in any issue title, body, or label.
- Do not modify `feature_list.json` unless issues were successfully created.
- If the goal touches auth, payments, migrations, or prod infra, flag it prominently in the epic's Risks section.

## Output

Emit the plan in this structure (markdown fenced block for easy copy-paste):

```md
## Issue Plan — <goal summary>

### Epic: <epic title>
**Labels:** type:epic · priority:<p> · <modifiers>

**Summary:** <one paragraph>

**Goals:**
- <goal 1>
- <goal 2>

**Non-goals:**
- <non-goal 1>

**Scope:** <modules/layers> — Estimate: <S|M|L|XL>

**Acceptance criteria:**
1. <criterion>
2. <criterion>

**Verification plan:**
- <command or step>

**Risks:**
- <risk>

**Release notes stub:** <one line>

---

### Sub-issues

#### [1] <sub-issue title>
**Labels:** type:task · priority:<p> · <parallel-safe|sequential-required> · <others>
**Parent:** #<epic>
**Parallel-safe:** yes | no
**Dependencies:** <none | sub-issue titles>
**Acceptance criteria:**
1. <criterion>
**Verification:** `<command>`

#### [2] <sub-issue title>
...

---

**Next step:** Run `/issue-plan` approval or create issues with `gh issue create`.
```

If issues were created, append a creation summary:

```
Issues created:
  #<n>  [epic]  <epic title>
  #<n>  [task]  <sub-issue title>
  ...
feature_list.json updated: feature id "<id>" → github_issue: <n>
```

## Related

- **Skills:** [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md)
- **Workflows:** [`github-issues.md`](../../.agents/workflows/github-issues.md), [`planning.md`](../../.agents/workflows/planning.md)
- **Commands:** `/issue-breakdown`, `/issue-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
