# {{PROJECT_NAME}} — Claude Code Workflow

<!-- FILL: Replace the placeholder above with your actual project name. -->

> TEMPLATE NOTE: This file is Claude Code-specific. It complements `AGENTS.md` — do not duplicate what is already there. Keep it concise (50–250 lines).

## Initialize a Session

Follow [`.agents/workflows/initialization.md`](.agents/workflows/initialization.md) at the start of every session. Steps in brief:

1. Read `AGENTS.md` → `CLAUDE.md` → `claude-progress.md` → `.agents/logs/progress.md` → `session-handoff.md`
2. Check `feature_list.json` for current status
3. Run `git status` and `git worktree list`
4. Create or select the correct worktree (see below)
5. Identify the next best action
6. Confirm verification commands from [`.agents/context/commands.md`](.agents/context/commands.md)
7. Select execution mode and model tier before doing implementation work

## Start from a Git Worktree

Every meaningful coding session uses a dedicated worktree. Full protocol: [`.agents/workflows/worktree-sessions.md`](.agents/workflows/worktree-sessions.md)

```bash
# Create a worktree for a new task
git worktree add ../{{REPO_NAME}}-worktrees/feat/my-feature feat/my-feature

# Copy env files (never stage them)
cp .env ../{{REPO_NAME}}-worktrees/feat/my-feature/.env
# Verify ignored
git -C ../{{REPO_NAME}}-worktrees/feat/my-feature status
```

Worktree directory pattern: `../{{REPO_NAME}}-worktrees/<branch-name>`

Context: [`.agents/context/worktrees.md`](.agents/context/worktrees.md)

## Inspect Progress

```bash
# Snapshot
cat claude-progress.md

# Detailed log
cat .agents/logs/progress.md

# Feature status
cat feature_list.json

# Last handover
cat session-handoff.md
```

## Select Work

1. Open `feature_list.json`
2. Find the highest-priority feature with `status: "not_started"` or `status: "in_progress"`
3. Check `parallel_safe` and `dependencies` before starting
4. Only one feature should be `in_progress` unless parallel work is confirmed safe
5. Create a sprint contract in `.agents/logs/progress.md` before implementing

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

## Use Project Commands, Skills & Loops

This repo ships its own invokable Claude Code surfaces under [`.claude/`](.claude/). Prefer them over re-deriving a procedure:

- **Slash commands** — [`.claude/commands/`](.claude/commands/), indexed in [`.agents/context/slash-commands.md`](.agents/context/slash-commands.md). Highlights: `/gated-orchestration`, `/review-10x`, `/review-pr`, `/security-review`, `/architecture-review`, `/context-map`, `/refresh-context`, `/create-command`, `/create-skill`, `/final-handoff`.
- **Skills** — [`.claude/skills/`](.claude/skills/), indexed in [`.agents/context/skills.md`](.agents/context/skills.md). They back the commands (e.g. `/review-10x` → `opus-code-review`).
- **Autonomous loops** — bounded, review-gated loops in [`.agents/workflows/autonomous-loops.md`](.agents/workflows/autonomous-loops.md): `/build-loop` (impl, 6), `/review-loop` (10), `/fix-loop` (10), `/test-loop` (6), `/docs-loop` (4), `/issue-loop` (6), `/skill-evolution-loop` (3). Each has a hard cap and a stop condition — never loop unbounded.

> The implementation loop is `/build-loop`, **not** `/loop` (Claude Code's built-in interval scheduler). When you repeat a procedure, capture it with `/create-command` or `/create-skill`.

## Use Subagents

Spawn a subagent when you need focused isolation without polluting the main context:
- Investigate why a specific test is failing
- Audit a bounded module for risks
- Verify a feature matches acceptance criteria
- Review a PR diff for bugs
- Find all usages of a component or pattern

A subagent returns a compact summary. The main session then decides what to do with the result.

This harness ships **reusable, model-tiered subagent roles** in [`.claude/agents/`](.claude/agents/) — `planner`/`architect`/`reviewer`/`safety-reviewer`/`integrator`/`skill-smith` (opus), `implementer`/`tester`/`debugger`/`docs-writer` (sonnet), `scout` (haiku, read-only). Dynamic workflows delegate to these in parallel via `agentType`. Index + tiering: [`.agents/context/subagents.md`](.agents/context/subagents.md).

Full guidance: [`.agents/workflows/orchestration.md`](.agents/workflows/orchestration.md)

## When to Use Agent Teams

Use agent teams only when collaboration between multiple Claude Code sessions is genuinely valuable:
- Complex feature spanning multiple ownership boundaries
- Large refactor with independent modules
- Parallel code review with specialized roles (security, architecture, UX, tests)
- Competing debugging hypotheses that benefit from parallel exploration

Do not use agent teams for simple tasks. Coordination overhead must be worth it.

Full workflow, roles, and assessment format: [`.agents/workflows/agent-teams.md`](.agents/workflows/agent-teams.md)

## When to Use Dynamic Workflows

Use dynamic workflows for repeatable, scriptable, many-subagent orchestration:
- Repo-wide audit (security, accessibility, test coverage, docs freshness)
- Large mechanical migrations
- Dependency upgrade audits
- Cross-module architecture review

Dynamic workflows differ from agent teams: workers don't need to talk to each other — they only return structured findings.

Full workflow: [`.agents/workflows/dynamic-workflows.md`](.agents/workflows/dynamic-workflows.md)

## Reviewer Feedback Loop

For non-trivial tasks, run the autonomous reviewer loop:

1. Plan → implement → implementation agent verifies as much as possible
2. Reviewer scores output from 1–10
3. Reviewer gives verdict: `PASS` / `REVISE` / `BLOCK`
4. Fix Critical and Major issues
5. Repeat until `Score: 10/10` + `Verdict: PASS` — or max 6 iterations

**Strict mode rule:** PASS requires 10/10. A reviewer cannot pass work below 10/10 in an autonomous loop.

If max iterations are reached: stop, document remaining Minor/Nit issues, create follow-up issues, record final verdict.

Rubric: [`evaluator-rubric.md`](evaluator-rubric.md)
Full workflow: [`.agents/workflows/review.md`](.agents/workflows/review.md)

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

Handover format: [`.agents/workflows/handover.md`](.agents/workflows/handover.md)

Keep handovers compact. A future session reads the handover, not raw logs.

## Model Tiering

Select the model tier that matches the task risk and complexity:

| Tier | Use for |
|---|---|
| **Opus-level** | Architecture planning, security review, high-risk refactors, final review/evaluation, failure root-cause analysis, harness design changes |
| **Sonnet-level** | General implementation, debugging, writing tests, refactoring, docs, routine feature work |
| **Haiku-level** | Trivial edits, formatting, simple docs updates, low-risk mechanical changes |

Before escalating to a stronger model, confirm: Is this high-risk? Architecture-level? Review/evaluation? Would the cheaper model likely be sufficient?

## Deeper Documentation

| Topic | File |
|---|---|
| Full initialization checklist | [`.agents/workflows/initialization.md`](.agents/workflows/initialization.md) |
| Planning workflow | [`.agents/workflows/planning.md`](.agents/workflows/planning.md) |
| Implementation workflow | [`.agents/workflows/implementation.md`](.agents/workflows/implementation.md) |
| Debugging workflow | [`.agents/workflows/debugging.md`](.agents/workflows/debugging.md) |
| Testing workflow | [`.agents/workflows/testing.md`](.agents/workflows/testing.md) |
| Release workflow | [`.agents/workflows/release.md`](.agents/workflows/release.md) |
| Orchestration decision matrix | [`.agents/workflows/orchestration.md`](.agents/workflows/orchestration.md) |
| Autonomous loops | [`.agents/workflows/autonomous-loops.md`](.agents/workflows/autonomous-loops.md) |
| Slash command index | [`.agents/context/slash-commands.md`](.agents/context/slash-commands.md) |
| Skill and superpower index | [`.agents/context/skills.md`](.agents/context/skills.md) |
| Architecture context | [`.agents/context/architecture.md`](.agents/context/architecture.md) |
| Conventions | [`.agents/context/conventions.md`](.agents/context/conventions.md) |
| Known issues | [`.agents/context/known-issues.md`](.agents/context/known-issues.md) |
| Harness index | [`.agents/README.md`](.agents/README.md) |
| AGENTS.md | [`AGENTS.md`](AGENTS.md) |
