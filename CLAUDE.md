# {{PROJECT_NAME}} — Claude Code Workflow

<!-- FILL: Replace the placeholder above with your actual project name. -->

> TEMPLATE NOTE: This file is the **Claude Code adapter** for the harness — it complements `AGENTS.md` and must not duplicate it. The runtime-agnostic portability model lives in [`.agents/context/runtimes.md`](.agents/context/runtimes.md). Keep this file concise (50–250 lines).

## Initialize a Session

Follow [`.agents/workflows/initialization.md`](.agents/workflows/initialization.md) for the full session-start checklist (reading order, worktree setup, feature selection, verification commands, model-tier selection). Required reading order and hard constraints live in [`AGENTS.md`](AGENTS.md).

## Start from a Git Worktree

Every meaningful coding session uses a dedicated worktree — full protocol and branch conventions: [`.agents/context/worktrees.md`](.agents/context/worktrees.md).

```bash
# Safe, validated helper — validates prefix, creates worktree, copies env files
bash scripts/worktree.sh create <branch>
```

In-repo worktrees (under `./worktrees/`) are covered by `.gitignore`; arbitrary in-repo paths are auto-excluded via `.git/info/exclude`.

## Use `/frontend-design`

Invoke `/frontend-design` when:
- Implementing or reviewing any UI, layout, or visual component
- Checking responsive behavior
- Verifying accessibility basics
- Capturing before/after screenshots for demo evidence
- Reviewing design polish or UX direction

Do not invoke it for backend-only or non-visual work.

## Use `/superpowers:*` Skills

Before implementing a repeated or specialized task, check [`.agents/context/skills.md`](.agents/context/skills.md) and the available skills list.

Common patterns:
- `/superpowers:test-driven-development` — before writing new features
- `/superpowers:systematic-debugging` — when root cause is unclear
- `/superpowers:verification-before-completion` — before marking any task done
- `/superpowers:requesting-code-review` / `/superpowers:receiving-code-review` — for reviewer loops
- `/superpowers:finishing-a-development-branch` — for clean handover and PR prep

Use a skill when it improves quality, consistency, speed, or verification. Do not invoke skills for the sake of it.

## Use Commands, Skills & Loops

Prefer the harness's invokable surfaces over re-deriving procedures. Slash commands index: [`.agents/context/slash-commands.md`](.agents/context/slash-commands.md); skills index: [`.agents/context/skills.md`](.agents/context/skills.md); loop schema, caps, and stop conditions: [`.agents/workflows/autonomous-loops.md`](.agents/workflows/autonomous-loops.md).

> The implementation loop is `/build-loop`, **not** `/loop` (Claude Code's built-in interval scheduler). When you repeat a procedure, capture it with `/create-command` or `/create-skill`.

## Spawn Subagents

Spawn a subagent when you need focused isolation without polluting the main context:
- Investigate why a specific test is failing
- Audit a bounded module for risks
- Verify a feature matches acceptance criteria
- Review a PR diff for bugs
- Find all usages of a component or pattern

Reusable, model-tiered roles in [`.claude/agents/`](.claude/agents/): `planner`/`architect`/`reviewer`/`safety-reviewer`/`integrator`/`skill-smith` (opus), `implementer`/`tester`/`debugger`/`docs-writer` (sonnet), `scout` (haiku, read-only). Index + tiering: [`.agents/context/subagents.md`](.agents/context/subagents.md).

For agent teams and dynamic workflows see [`.agents/workflows/orchestration.md`](.agents/workflows/orchestration.md).

Strict review loop, scoring, and verdict rules: [`.agents/workflows/review.md`](.agents/workflows/review.md) (rubric: [`evaluator-rubric.md`](evaluator-rubric.md)).

## Verify Work

Run verification before every handoff. Match the verification scope to the change type:

| Change type | Verification steps |
|---|---|
| Frontend | lint, typecheck, targeted tests, build, screenshot |
| Backend | lint, typecheck, unit/integration tests, smoke test |
| Docs only | markdown lint, link check, readability check |
| Contracts / DB | compile, unit tests, migration dry-run |

If verification cannot run, document: what was attempted, why it failed, what risk remains, what to check next.

Commands: [`.agents/context/commands.md`](.agents/context/commands.md)

## Create Compact Handovers

At the end of every significant session:

```bash
# Update root snapshot
edit claude-progress.md

# Append to log
edit .agents/logs/handover.md

# Update root handoff file (single latest entry)
edit session-handoff.md
```

Handover format: [`.agents/workflows/handover.md`](.agents/workflows/handover.md). Keep handovers compact — a future session reads the handover, not raw logs.

## Model Tiering

Select the model tier that matches the task risk and complexity:

| Tier | Use for |
|---|---|
| **Opus-level** | Architecture planning, security review, high-risk refactors, final review/evaluation, failure root-cause analysis, harness design changes |
| **Sonnet-level** | General implementation, debugging, writing tests, refactoring, docs, routine feature work |
| **Haiku-level** | Trivial edits, formatting, simple docs updates, low-risk mechanical changes |

Before escalating to a stronger model, confirm: Is this high-risk? Architecture-level? Review/evaluation? Would the cheaper model likely be sufficient?

Full model-tier detail and subagent roles: [`.agents/context/subagents.md`](.agents/context/subagents.md). Deeper docs index: [`AGENTS.md`](AGENTS.md).
