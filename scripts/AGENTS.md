# Context: `scripts/`

## Purpose

Repo-level scripts. Today this is the harness's verification engine — the one place that defines "is this harness healthy?" — run identically by humans and CI.

## Important Files

| Path | What it is |
|---|---|
| `verify-harness.sh` | Single source of verification truth: structure, length limits, JSON/YAML validity, link resolution, no-attribution, no-secrets, schema checks, shell syntax. Flags: `--json` (machine-readable), `--scans-only` (content scans only), `--help`; `HARNESS_VERIFY_ROOT` overrides the scan root. Exports `EXCLUDE_DIRS` before any checks run so `test-verify-harness.sh` can source it. |
| `test-verify-harness.sh` | Hermetic regression test for `verify-harness.sh` — sources `verify-harness.sh` to obtain `EXCLUDE_DIRS` (single source of truth), then drives `--scans-only` against throwaway fixture roots to prove exclusions hold (closes bug #5). Run by CI after the harness verification step. |
| `provision.sh` | One-shot provisioning CLI: fills `{{PLACEHOLDER}}` tokens, detects the stack via `lib/stack-detection.sh`, validates with `verify-harness.sh`. Flags: `--config`, `--name`, `--owner`, `--repo`, `--dry-run`, `--non-interactive`. |
| `sync-ledger.sh` | Reconcile `feature_list.json` with live GitHub Issue state; report drift or cautiously update with `--fix`. Local tool — never run by CI. |
| `worktree.sh` | Safe worktree helper: create (sibling or in-repo with auto-exclude), list, remove, prune; validates branch prefix; copies env files safely. |
| `lib/common.sh` | Shared colour variables (`RED GREEN YELLOW CYAN BOLD RESET`) and output helpers (`section` `ok` `warn`). Sourced by `init.sh`, `provision.sh`, `verify-harness.sh`, `sync-ledger.sh`, `worktree.sh`. |
| `lib/stack-detection.sh` | `detect_stack()` function — detects the project stack and sets `_STACK_NAME`, `_STACK_PM`, `_STACK_INSTALL`, `_STACK_DEV`, `_STACK_BUILD`, `_STACK_LINT`, `_STACK_TYPECHECK`, `_STACK_TEST`, `_STACK_FORMAT`. Sourced by `init.sh` and `provision.sh`. |
| `AGENTS.md` | This file |

## How This Directory Is Used

**Shared library (`lib/`):** All scripts source `lib/common.sh` for colour variables and basic helpers (`section`, `ok`, `warn`). Scripts that detect the project stack also source `lib/stack-detection.sh` and call `detect_stack()`. Each script sets `SCRIPT_DIR` via `"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` before the source calls so paths resolve correctly regardless of the caller's working directory.

**Verification workflow:** `verify-harness.sh` is run locally before a PR and by `.github/workflows/ci.yml` on every push/PR. It is non-destructive and read-only, and it exits non-zero on any failure. It exports `EXCLUDE_DIRS` before running any checks; `test-verify-harness.sh` sources it to obtain the list rather than maintaining a separate hardcoded copy.

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

- Scans that don't exclude `node_modules`/build output produce false positives locally (issue #5 — **RESOLVED**: exclude-dir list is single-sourced via `EXCLUDE_DIRS` and regression-tested by `test-verify-harness.sh`). New content scans must still derive their pruning from `EXCLUDE_DIRS`.
- A check that prints but doesn't increment `FAILED` will pass CI silently — always use `fail()`.

## Recent Decisions

- 2026-06-03 — Single source of verification truth. 2026-06-20 — Extended with command/skill/context schema checks. See [`../.agents/logs/decisions.md`](../.agents/logs/decisions.md).

## Update Rules

When the harness gains a surface or rule, add the matching check here and note it in [`../.agents/logs/changelog.md`](../.agents/logs/changelog.md). Keep the file-header comment's check list current.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
