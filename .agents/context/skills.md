# Skills

Discovered skills, superpowers, MCP tools, and repo-specific scripts available in this project.

## When to Use Skills

Use a skill when it improves **quality, speed, consistency, verification, or design**. Do not invoke a skill just for the sake of using one.

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
