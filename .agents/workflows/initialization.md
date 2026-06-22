# Initialization Workflow

Every session must complete this workflow before doing any implementation work.

**When to use:** Start of every agent session — no exceptions.

---

## 19-Step Session Start

### Step 1 — Read AGENTS.md
Open [`../../AGENTS.md`](../../AGENTS.md). Understand the project overview, hard constraints, definition of done, and verification rules. Do not skip.

### Step 2 — Read CLAUDE.md (Claude Code only)
Open `../../CLAUDE.md`. Understand Claude-specific workflow, model tiering, and superpower usage guidance.

### Step 3 — Read claude-progress.md
Open [`../../claude-progress.md`](../../claude-progress.md). Note current phase, current task, and any blockers.

### Step 4 — Read .agents/logs/progress.md
Open `../../.agents/logs/progress.md`. Cross-check with `claude-progress.md`. Resolve any discrepancies before proceeding.

### Step 5 — Read session-handoff.md
Open [`../../session-handoff.md`](../../session-handoff.md). Note completed work, in-progress work, next best action, open issues, and any worktree/env state from the previous session.

### Step 6 — Check feature_list.json
Open [`../../feature_list.json`](../../feature_list.json). Identify which features are `not_started`, `in_progress`, or `blocked`. Confirm only one feature should be `in_progress` unless parallel work is explicitly safe.

### Step 7 — Check current Git branch and status
```
git status
git branch --show-current
git log --oneline -10
```
Understand the working tree state before touching anything.

### Step 8 — Check current git worktrees
```
git worktree list
```
Know which worktrees are active, which branches they track, and whether any are stale.

### Step 9 — Create or select the correct worktree for this session
Determine whether to:
- Use an existing worktree for the target branch, or
- Create a new worktree following the naming convention in [`../context/worktrees.md`](../context/worktrees.md)

Default worktree directory pattern: `../<repo-name>-worktrees/<branch-name>`

Branch naming:
```
feat/<short-description>
fix/<short-description>
docs/<short-description>
chore/<short-description>
refactor/<short-description>
test/<short-description>
harness/<short-description>
```

### Step 10 — Copy required local env files into the worktree
Copy env files from the default branch worktree or nearest existing worktree where they exist.

Env files to look for:
```
.env
.env.local
.env.development
.env.test
.env.production.local
apps/*/.env
packages/*/.env
```

Never stage env files. Never print secret values.

### Step 11 — Verify copied env files are ignored and not staged
```
git status
git diff --cached
```
Confirm no env files appear in staged changes. If they do, unstage immediately and fix `.gitignore`.

### Step 12 — Check current GitHub issues and PRs (if available)
```
gh issue list --state open
gh pr list --state open
```
Understand which issues are assigned, in review, or blocked. Link this session's work to the relevant issue before starting.

## What's Next

After gathering context (Steps 1–12), determine your path forward:

1. **Identify the highest-priority unfinished work** — what is blocked, what is the concrete first step?
2. **Confirm verification commands** — see [`../context/commands.md`](../context/commands.md)
3. **Select execution mode and model tier** — see [`./orchestration.md`](./orchestration.md) for the full decision matrix
4. **Write a sprint contract** — see [`./planning.md`](./planning.md) for the full format and steps; store it in [`../logs/progress.md`](../logs/progress.md)

For any non-trivial task, do not skip the sprint contract.

---

## Related Files

- [`../../AGENTS.md`](../../AGENTS.md) — project root instructions
- [`../../claude-progress.md`](../../claude-progress.md) — current progress state
- [`../../session-handoff.md`](../../session-handoff.md) — last session handover
- [`../../feature_list.json`](../../feature_list.json) — machine-readable feature tracker
- [`../context/worktrees.md`](../context/worktrees.md) — worktree conventions, branch naming, env-file rules
- [`./orchestration.md`](./orchestration.md) — execution mode decision matrix
- [`./planning.md`](./planning.md) — sprint contract format and planning steps

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
