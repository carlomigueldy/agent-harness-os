# Session Handoff — {{PROJECT_NAME}}

> This file holds the **latest** session handover.
> The rolling archive of all past handovers lives in [.agents/logs/handover.md](.agents/logs/handover.md).
> Overwrite this file at the end of every session; append to the archive log.

---

## Handover — YYYY-MM-DD HH:mm

### Current State

<!-- FILL: one-paragraph snapshot of where the project stands right now -->
Harness initialized. No features have been implemented yet. Next session should read all context files and select the first task from `feature_list.json`.

### Completed

- Harness OS scaffolded (`AGENTS.md`, `CLAUDE.md`, `.agents/**`, `.github/**`, root state files)
- `feature_list.json` seeded with example features — replace with real features
- `claude-progress.md` dashboard created
- `clean-state-checklist.md` and `evaluator-rubric.md` created
- `init.sh` created for session bootstrapping

### In Progress

- `<!-- nothing in flight — first real feature TBD -->`

### Next Best Action

1. Read `AGENTS.md`, `CLAUDE.md`, and `claude-progress.md`
2. Run `bash init.sh` to confirm baseline state
3. Replace example entries in `feature_list.json` with real project features
4. Create a worktree for the first feature: `git worktree add ../{{REPO_NAME}}-worktrees/feat/my-first-feature feat/my-first-feature`
5. Open the first GitHub Issue and link it in `feature_list.json`

### Important Files

- `AGENTS.md` — harness entry point and hard constraints
- `CLAUDE.md` — Claude Code session workflow
- `feature_list.json` — machine-readable feature state (update each session)
- `claude-progress.md` — human-readable dashboard (update each session)
- `.agents/logs/progress.md` — detailed sprint contracts and orchestration logs
- `.agents/context/commands.md` — all verified commands for this project

### Worktree / Branch

- Branch: `{{DEFAULT_BRANCH}}`
- Worktree path: *(main repo — no worktree created yet)*
- Env file status: *(not yet checked — run `init.sh` to see env file status)*

### Commands Run

- *(none yet — this is the template seed handover)*

### Verification

- Baseline verification: not yet run
- Run `bash init.sh VERIFY=1` to attempt baseline lint/typecheck/tests

### Demo / Evidence

- None yet

### Reviewer Score / Verdict

- Score: *(not yet reviewed)*
- Verdict: *(not yet reviewed)*

### Open Issues / PRs

- None yet — create issues after filling in real features

### Blockers / Risks

- `feature_list.json` contains example/placeholder features — must be replaced before real work begins
- `claude-progress.md` dashboard values are placeholders — update after first discovery run
- Env files not yet confirmed — run `init.sh` to check

### Context to Preserve

- This is a **template repository**. All `{{PLACEHOLDER}}` values must be filled in by the consuming project's initialization workflow (see `.agents/workflows/initialization.md`).
- Do not hardcode any framework, company, or tech stack at the root level of this template.
- The init workflow lives in `.agents/workflows/initialization.md`.

### Recommended Next Mode

Planning — read context, fill in real feature list, create first GitHub issues, then select a feature and write a sprint contract before implementing.
