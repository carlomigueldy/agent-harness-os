# Context: `scripts/`

## Purpose

Repo-level scripts. Today this is the harness's verification engine — the one place that defines "is this harness healthy?" — run identically by humans and CI.

## Important Files

| Path | What it is |
|---|---|
| `verify-harness.sh` | Single source of verification truth: structure, length limits, JSON/YAML validity, link resolution, no-attribution, no-secrets, schema checks, shell syntax |
| `provision.sh` | One-shot provisioning CLI: fills `{{PLACEHOLDER}}` tokens, detects the stack (Node/Python/Rust/Go/Ruby/PHP/Java/.NET/Elixir), validates with `verify-harness.sh`. Flags: `--config`, `--name`, `--owner`, `--repo`, `--dry-run`, `--non-interactive`. |
| `sync-ledger.sh` | Reconcile `feature_list.json` with live GitHub Issue state; report drift or cautiously update with `--fix`. Local tool — never run by CI. |
| `worktree.sh` | Safe worktree helper: create (sibling or in-repo with auto-exclude), list, remove, prune; validates branch prefix; copies env files safely |
| `AGENTS.md` | This file |

## How This Directory Is Used

`verify-harness.sh` is run locally before a PR and by `.github/workflows/ci.yml` on every push/PR. It is non-destructive and read-only, and it exits non-zero on any failure.

## Agent Rules

- `verify-harness.sh` must stay **non-destructive and read-only** — it inspects, it never mutates the repo.
- Keep it the **single** verification entry point. Add new checks as numbered sections here rather than creating parallel scripts (see decision 2026-06-03).
- Each check prints a clear pass/fail line and increments the pass/fail counters so the summary stays accurate.
- When you add a harness surface (commands, skills, context files), add a corresponding schema check here so the surface can't silently rot.
- Keep it portable: bash + `python3` (+ optional `pyyaml`/`ruby`). Degrade with a warning if an optional tool is missing; never hard-fail on a missing optional parser silently.

## Common Workflows

- **Run verification:** `bash scripts/verify-harness.sh`.
- **Provision a new repo:** `bash scripts/provision.sh --config harness.config` (non-interactive) or `bash scripts/provision.sh` (interactive). Preview first with `--dry-run`.
- **Create a worktree:** `bash scripts/worktree.sh create feat/my-feature` (sibling, default) or `--in-repo` (created under `./worktrees/`, auto-excluded via `.git/info/exclude`); env files are copied safely.
- **Remove a worktree:** `bash scripts/worktree.sh remove feat/my-feature` (refuses if uncommitted/unmerged; add `--force` to override).
- **Add a check:** append a numbered `hdr "N. ..."` section using `pass`/`fail`/`warn`; update the count in the file header comment.
- **Debug a CI failure of this script:** `/ci-debug`.
- **Reconcile the feature ledger:** `bash scripts/sync-ledger.sh` (report drift only) or `bash scripts/sync-ledger.sh --fix` (cautious update). See also `/sync-ledger`.

## Commands

`/ci-debug`, `/release-check`. See [`../.agents/context/slash-commands.md`](../.agents/context/slash-commands.md).

## Skills

[`test-debugging`](../.claude/skills/test-debugging/SKILL.md), [`release-readiness`](../.claude/skills/release-readiness/SKILL.md).

## Testing / Validation

The script validates itself by running clean on a healthy tree. `shellcheck --severity=error scripts/*.sh` runs in CI (informational). Test new checks by temporarily breaking a file and confirming the check fails, then reverting.

## Known Risks

- Scans that don't exclude `node_modules`/build output produce false positives locally (see issue #5). New content scans must scope their globs.
- A check that prints but doesn't increment `FAILED` will pass CI silently — always use `fail()`.

## Recent Decisions

- 2026-06-03 — Single source of verification truth. 2026-06-20 — Extended with command/skill/context schema checks. See [`../.agents/logs/decisions.md`](../.agents/logs/decisions.md).

## Update Rules

When the harness gains a surface or rule, add the matching check here and note it in [`../.agents/logs/changelog.md`](../.agents/logs/changelog.md). Keep the file-header comment's check list current.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
