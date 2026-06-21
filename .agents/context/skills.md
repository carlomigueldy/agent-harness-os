# Skills

Discovered skills, superpowers, MCP tools, and repo-specific scripts available in this project.

## When to Use Skills

Use a skill when it improves **quality, speed, consistency, verification, or design**. Do not invoke a skill just for the sake of using one.

> **Other runtimes:** In Claude Code, project skills live in `.claude/skills/`. Other runtimes reference the equivalent procedures directly in `.agents/workflows/`. See [`runtimes.md`](runtimes.md) for the full concept mapping.

## Harness-Level Skills (Always Available)

| Skill / Superpower | When to Use |
|-------------------|-------------|
| `/superpowers:writing-plans` | Before any non-trivial task — create a sprint contract |
| `/superpowers:executing-plans` | During implementation following an approved plan |
| `/superpowers:systematic-debugging` | When diagnosing a bug or failure — follow structured root-cause analysis |
| `/superpowers:test-driven-development` | When writing new features with tests first |
| `/superpowers:verification-before-completion` | Before handing off — run the verification checklist |
| `/superpowers:requesting-code-review` | When opening a PR or requesting a reviewer pass |
| `/superpowers:receiving-code-review` | When acting on reviewer feedback |
| `/superpowers:finishing-a-development-branch` | When closing out a feature branch — cleanup, PR, handover |
| `/superpowers:using-git-worktrees` | When setting up or managing a session worktree |
| `/superpowers:subagent-driven-development` | When delegating focused investigation to a subagent |
| `/superpowers:dispatching-parallel-agents` | When work is parallel-safe and multiple agents can run concurrently |
| `/superpowers:brainstorming` | When exploring options before committing to an approach |
| `/superpowers:using-superpowers` | When unsure which superpower applies — start here |
| `/frontend-design` | For any frontend, UI/UX, visual design, layout, accessibility, or screenshot-driven work |
| `/code-review` | For reviewing a diff against the evaluator rubric |

## Project Skills (`.claude/skills/`)

Project skills are reusable, on-demand procedures that live in [`../../.claude/skills/`](../../.claude/skills/), one per directory as `<name>/SKILL.md`. Claude Code discovers them by their frontmatter `description` and loads the body when the task matches. They encode the harness's own recurring agent workflows.

See [`../../.claude/skills/AGENTS.md`](../../.claude/skills/AGENTS.md) for the directory's local guide, and use the [skill-authoring](../../.claude/skills/skill-authoring/SKILL.md) skill (or `/create-skill`) to add new ones.

### Skill File Schema

`verify-harness.sh` checks the frontmatter and required headings of every `SKILL.md`.

````md
---
name: <lower-kebab-case — MUST equal the directory name>
description: <one line — when to use this skill; this is what triggers discovery>
---

# Skill: <name>

## Purpose
What this skill does.

## When to Use
Concrete triggers.

## When Not to Use
Anti-triggers — when a different skill or no skill is better.

## Inputs
What the skill needs to start.

## Outputs
What it produces.

## Procedure
1. Numbered, repeatable steps.

## Checks
Verifications to run before declaring the skill's work done.

## Common Failure Modes
What goes wrong and how to avoid it.

## Example Usage
A short worked example.

## Related Commands
`/command` entries that invoke or compose with this skill.

## Maintenance Notes
What to update when the repo changes.
````

**Required frontmatter:** `name`, `description` (and `name` must equal the directory). **Required headings:** `## Purpose`, `## When to Use`, `## When Not to Use`, `## Procedure`, `## Checks`, `## Related Commands`.

### Project Skill Index

| Skill | Purpose |
|---|---|
| [`repo-discovery`](../../.claude/skills/repo-discovery/SKILL.md) | Inventory an unfamiliar repo (stack, commands, CI, gaps) into a discovery report |
| [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md) | Turn goals into epics + labeled sub-issues with acceptance criteria |
| [`context-mapping`](../../.claude/skills/context-mapping/SKILL.md) | Create/refresh recursive `AGENTS.md`/`CLAUDE.md` context maps without drift |
| [`command-authoring`](../../.claude/skills/command-authoring/SKILL.md) | Author a schema-conformant `.claude/commands/` slash command |
| [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md) | Author a schema-conformant `.claude/skills/` project skill |
| [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md) | Design a bounded autonomous loop with stop/escalation/handoff |
| [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) | Run a strict 10/10 Opus review against the evaluator rubric |
| [`security-review`](../../.claude/skills/security-review/SKILL.md) | Review changes for secrets, authz, injection, and unsafe automation |
| [`test-debugging`](../../.claude/skills/test-debugging/SKILL.md) | Systematically diagnose and fix a failing test |
| [`documentation-maintenance`](../../.claude/skills/documentation-maintenance/SKILL.md) | Keep docs accurate, linked, and within length limits |
| [`handoff-writing`](../../.claude/skills/handoff-writing/SKILL.md) | Write a compact, complete session handover |
| [`release-readiness`](../../.claude/skills/release-readiness/SKILL.md) | Run the pre-release verification + changelog + clean-state gate |
| [`parallel-epic-delivery`](../../.claude/skills/parallel-epic-delivery/SKILL.md) | Orchestrate N epics in parallel across worktree lanes (Sonnet implements, Opus reviews to 10/10, PR + PR-diff review), then integration-verify the merged tree and land review-gated PRs on a green trunk |

> These skills pair with the slash commands indexed in [`slash-commands.md`](slash-commands.md) — e.g. `/review-10x` drives `opus-code-review`, `/create-skill` drives `skill-authoring`, `/gated-orchestration` drives `parallel-epic-delivery`.

## MCP Tools Available

<!-- FILL: List MCP tools confirmed available in this project's environment -->

| MCP Tool | Purpose | When to Use |
|----------|---------|-------------|
| <!-- FILL: e.g. Playwright MCP --> | <!-- FILL: e.g. Browser automation, E2E verification --> | <!-- FILL: e.g. Capturing screenshots, running browser tests --> |
| <!-- FILL: e.g. Supabase MCP --> | <!-- FILL: e.g. Database inspection and query --> | <!-- FILL: e.g. Checking data state during debugging --> |
| <!-- FILL: e.g. GitHub MCP --> | <!-- FILL: e.g. Issue and PR management --> | <!-- FILL: e.g. Creating issues, updating PRs --> |

> TEMPLATE NOTE: Run `/superpowers:using-superpowers` at session start to discover what is available. Update this table with confirmed tools.

## Project-Specific Scripts and Automation

<!-- FILL: List repo-specific scripts that function like skills -->

| Script / Command | Purpose | When to Use |
|-----------------|---------|-------------|
| <!-- FILL --> | <!-- FILL --> | <!-- FILL --> |

> TEMPLATE NOTE: Look for scripts in `package.json`, `Makefile`, `scripts/`, or `bin/`. Add any that are non-obvious.

## How to Propose a New Skill

If you notice a repeated task that would benefit from a dedicated skill or workflow:

1. Create a proposal file in [../proposals/README.md](../proposals/README.md) (or a new `.md` in `.agents/proposals/`).
2. Use the skill proposal format from the harness spec.
3. Tag the proposal with the affected workflow in [../workflows/workflow-improvement.md](../workflows/workflow-improvement.md).
4. Do not create a permanent skill without approval.

**Good candidates for new skills:**
- Add feature to a specific module (repeated pattern)
- Debug a recurring Playwright failure
- Create GitHub epic + sub-issues in one step
- Run full verification sequence
- Prepare a compact handover
- Review a PR against the evaluator rubric
- Audit context file freshness

## Model Tiering Quick Reference

| Task | Recommended Tier |
|------|-----------------|
| Architecture planning, security review, complex design | Opus-level |
| General implementation, tests, docs, debugging | Sonnet-level |
| Trivial edits, formatting, simple docs updates | Haiku-level |

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
