# Session Handoff — {{PROJECT_NAME}}

> This file holds the **latest** session handover (overwrite each session).
> Rolling archive lives in [`.agents/logs/handover.md`](.agents/logs/handover.md).
> Full handover format: [`.agents/workflows/handover.md`](.agents/workflows/handover.md).

---

## Handover — YYYY-MM-DD HH:mm

### Current State

<!-- FILL: one-paragraph snapshot of where the project stands right now -->
Harness initialized. No features have been implemented yet. Next session should read all context files and select the first task from `feature_list.json`.

### Completed

- Harness OS scaffolded (`AGENTS.md`, `CLAUDE.md`, `.agents/**`, `.github/**`, root state files)
- `feature_list.json` seeded with example features — replace with real features

### In Progress

- `<!-- nothing in flight — first real feature TBD -->`

### Next Best Action

1. Read `AGENTS.md`, `CLAUDE.md`, and `claude-progress.md`
2. Run `bash init.sh` to confirm baseline state
3. Replace example entries in `feature_list.json` with real project features
4. Create a worktree for the first feature: `bash scripts/worktree.sh create feat/my-first-feature`
5. Open the first GitHub Issue and link it in `feature_list.json`

### Worktree / Branch

- Branch: `{{DEFAULT_BRANCH}}`
- Worktree: *(main repo — no worktree created yet)*

### Verification

- Baseline verification: not yet run — run `VERIFY=1 bash init.sh` to attempt lint/typecheck/tests

### Reviewer Score / Verdict

- Score: *(not yet reviewed)*
- Verdict: *(not yet reviewed)*

### Blockers / Risks

- `feature_list.json` contains example/placeholder features — must be replaced before real work begins
- `claude-progress.md` values are placeholders — update after first discovery run

### Context to Preserve

- This is a **template repository**. All `{{PLACEHOLDER}}` values must be filled in via the [adoption workflow](.agents/workflows/adoption.md).
- Do not hardcode any framework, company, or tech stack at the root level of this template.
