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
- Create a new worktree following the naming convention in [`./worktree-sessions.md`](./worktree-sessions.md)

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

### Step 13 — Identify the next best action
Using all context gathered in steps 1–12, state clearly:
- What is the highest-priority unfinished work?
- Is there a blocker that prevents that work?
- What is the concrete first step?

### Step 14 — Confirm verification commands
Review `../../.agents/context/commands.md`. Know which commands will be used to verify the work for this session before implementation begins.

### Step 15 — Discover relevant skills and superpowers
Check `../../.agents/context/skills.md`. Identify:
- Applicable `/superpowers:*` skills
- Whether `/frontend-design` applies to this session's work
- Any project-specific skills documented there

### Step 16 — Select execution mode
Choose one:

| Mode | Use When |
|---|---|
| **Single agent** | Small/medium tasks, shared files, unclear requirements |
| **Subagent** | Focused investigation, isolated second opinion, parallel research |
| **Agent team** | Complex cross-module work, roles need to collaborate |
| **Dynamic workflow** | Repeatable many-worker audits, migrations, verifications |
| **Sequential manual** | High-risk changes (auth, payments, migrations, secrets) |

See [`./orchestration.md`](./orchestration.md) for the full decision matrix.

### Step 17 — Select model tier

| Tier | Use For |
|---|---|
| **Opus-level** | Architecture, security review, final evaluation, complex RCA |
| **Sonnet-level** | General implementation, debugging, tests, refactoring |
| **Haiku-level** | Trivial edits, formatting, simple docs updates |

### Step 18 — Decide whether work is sequential or parallel-safe
Parallel work requires genuinely independent workstreams with no shared file edits, clear dependency order, and explicit worktree assignments. When in doubt, choose sequential.

### Step 19 — Create or update a sprint contract before implementation
For any non-trivial task, write a sprint contract (see format below) in `../../.agents/logs/progress.md` before writing a single line of implementation code.

---

## Sprint Contract Format

Store active sprint contracts in `../../.agents/logs/progress.md`.

```md
## Sprint Contract — Task Name

### Goal
What needs to be achieved.

### Scope
What will be changed.

### Non-goals
What will not be changed.

### Acceptance Criteria
- ...

### Verification Plan
- ...

### Demo Plan
- ...

### Dependencies
- ...

### Blockers
- ...

### Worktree
Branch/path/env status.

### Skills / Superpowers
Relevant `/frontend-design` or `/superpowers:*` usage.

### Orchestration Mode
Single agent / subagent / agent team / dynamic workflow / sequential manual.

### Parallelization Assessment
Sequential required / parallel-safe.

### Risk Level
Low / medium / high.

### Model Tier
Haiku / Sonnet / Opus-level.

### Done Means
Clear definition of done.
```

No non-trivial task should start without this.

---

## Related Files

- [`../../AGENTS.md`](../../AGENTS.md) — project root instructions
- [`../../claude-progress.md`](../../claude-progress.md) — current progress state
- [`../../session-handoff.md`](../../session-handoff.md) — last session handover
- [`../../feature_list.json`](../../feature_list.json) — machine-readable feature tracker
- [`./worktree-sessions.md`](./worktree-sessions.md) — worktree creation and env file workflow
- [`./orchestration.md`](./orchestration.md) — execution mode decision matrix

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
