# Handover Archive

Rolling archive of session handovers for {{PROJECT_NAME}}. Newest entries on top.

At the end of every significant session, write a compact handover and prepend it here. Also update [../../session-handoff.md](../../session-handoff.md) with the latest entry.

See [../workflows/handover.md](../workflows/handover.md) for the full handover workflow.

## Format

```md
## Handover — YYYY-MM-DD HH:mm

### Current State
Brief status.

### Completed
- ...

### In Progress
- ...

### Next Best Action
1. ...
2. ...
3. ...

### Important Files
- `path/to/file` — why it matters

### Worktree / Branch
- Branch:
- Worktree path:
- Env file status:

### Commands Run
- `command` — result

### Verification
- ...

### Demo / Evidence
- ...

### Reviewer Score / Verdict
- Score:
- Verdict:

### Open Issues / PRs
- ...

### Blockers / Risks
- ...

### Context to Preserve
Important details the next session should not rediscover.

### Recommended Next Mode
Planning / implementation / review / debugging / testing / documentation.
```

Keep handovers compact. Do not dump the whole session.

---

<!-- FILL: Prepend new handover entries here (newest first). -->

## Handover — 2026-06-21

### Current State
Portability & delivery hardening complete on in-place epic branch `harness/portability-hardening`. Built by a dynamic workflow (4 parallel Sonnet implementers → Sonnet integrator → Opus reviewer + safety-reviewer 10/10 gate with Sonnet fixer). Opus review **PASS 10/10**, safety **PASS**, `verify-harness` **18/0**. Ready to land via a single PR + a second Opus PR-diff review before merge.

### Completed
- **Runtime-agnostic:** `.agents/context/runtimes.md` (core-vs-adapter model + mapping table + adapter contract); `.codex/` adapter (AGENTS.md/README.md/prompts/build-loop.md); `CLAUDE.md` reframed as the Claude Code adapter; `init.sh` stack detection 4→9 ecosystems.
- **Provisioning CLI:** `scripts/provision.sh` (placeholder fill + stack detect + verify; safe `--dry-run`/non-interactive/`--config`; refuse-to-clobber) + `harness.config.example`.
- **Epic/ledger sync:** `.github/workflows/epic-sync.yml` (closes epic-branch sub-issues, guarded off `main`); `scripts/sync-ledger.sh` (ledger↔issues, graceful without `gh`); `/sync-ledger`; `.agents/workflows/epic-delivery.md`; `feature_list.json` `epic` field.
- **Worktree gitignore:** `.gitignore` in-repo block + `scripts/worktree.sh` (`create`/`list`/`remove`/`prune`/`sync-exclude`); `sync-exclude` covers arbitrary names like `./claire`.

### Next Best Action
1. Open the PR to `main` (single PR; PR body documents the four workstreams + evidence).
2. Run the second Opus review loop on the PR diff; address any findings.
3. Merge on green; delete the epic branch.

### Worktree / Branch
- Branch: `harness/portability-hardening` (in-place; no separate worktree — see decision 2026-06-21)
- Env file status: none needed (docs/template repo)

### Verification
- `verify-harness.sh` 18/0; `bash -n` all scripts; `bash init.sh` clean; `provision.sh --dry-run` writes nothing; `sync-ledger.sh` graceful (0 drift); live `worktree.sh sync-exclude` excluded a hand-made `./claire`.

### Reviewer Score / Verdict
- Score: 10/10 · Verdict: PASS (safety PASS)

### Context to Preserve
- Root `claude-progress.md` / `session-handoff.md` stay template seeds by convention; real history lives in `.agents/logs/*`. No GitHub tracking issues on the template repo.

### Recommended Next Mode
Review → merge.

## Handover — 2026-06-03

### Current State
Harness template hardened. README + self-verifying CI + `scripts/verify-harness.sh` added on `harness/repo-hardening` and opened as PR #4 (Closes #1/#2/#3). Verification 11/11 local; reviewer PASS 10/10.

### Completed
- `README.md`, `scripts/verify-harness.sh`, `.github/workflows/ci.yml`.
- Logs recorded: changelog, decisions, verification, orchestration, retrospective, this handover.

### In Progress
- PR #4 awaiting CI green + merge.

### Next Best Action
1. Confirm CI is green on PR #4.
2. Merge PR #4 (squash, no AI attribution) — auto-closes #1/#2/#3.
3. Remove the worktree and prune the merged branch.

### Important Files
- `scripts/verify-harness.sh` — single source of verification truth (CI runs it).
- `.github/workflows/ci.yml` — CI entry point.
- `README.md` — GitHub landing page.

### Worktree / Branch
- Branch: `harness/repo-hardening`
- Worktree path: `../agent-harness-templates-worktrees/harness/repo-hardening`
- Env file status: none needed (no env files).

### Commands Run
- `bash scripts/verify-harness.sh` — 11 passed / 0 failed, exit 0.

### Verification
- Local verify 11/11; link-checker unit-tested; CI to confirm on PR #4.

### Demo / Evidence
- verify-harness.sh console output (11/0); CI run on PR #4.

### Reviewer Score / Verdict
- Score: 10/10 (round 2)
- Verdict: PASS

### Open Issues / PRs
- Epic #1; sub-issues #2 (README), #3 (CI); PR #4.

### Blockers / Risks
- None. Verification needs `python3` (+ `pyyaml`/`ruby`); CI installs `pyyaml`.

### Context to Preserve
- Root snapshot files (`claude-progress.md`, `session-handoff.md`) and `feature_list.json` are kept as pristine TEMPLATE SEEDS; this repo's live state lives in `.agents/logs/` and GitHub Issues (see `.agents/logs/decisions.md`).

### Recommended Next Mode
Review → merge, then planning for the next improvement (e.g. SHA-pin Actions, markdown lint).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
