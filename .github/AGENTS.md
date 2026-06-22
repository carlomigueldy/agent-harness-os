# Context: `.github/`

## Purpose

GitHub-facing configuration for the harness: issue forms, the PR template, and the CI that runs the harness's own verification. This is how the harness's "GitHub-issue-driven" and "self-verifying" principles are wired into the platform.

## Important Files

| Path | What it is |
|---|---|
| `ISSUE_TEMPLATE/epic.yml` | Epic issue form (`type: epic`) |
| `ISSUE_TEMPLATE/epic-subissue.yml` | Sub-issue form (`type: task`) |
| `ISSUE_TEMPLATE/bug_report.yml` | Bug form |
| `ISSUE_TEMPLATE/feature_request.yml` | Feature form |
| `ISSUE_TEMPLATE/config.yml` | Issue chooser config + contact links |
| `pull_request_template.md` | PR body template (summary, evidence, reviewer block, checklist) |
| `workflows/ci.yml` | CI — runs `scripts/verify-harness.sh` on push/PR to `main` |
| `workflows/epic-sync.yml` | Closes sub-issues referenced in a PR body when merged into an `epic/*` branch (fills GitHub's non-default-branch auto-close gap) |

## How This Directory Is Used

- Issue forms are surfaced when someone opens an issue; they enforce the fields the harness needs (acceptance criteria, parallel-safety, reviewer verdict).
- CI runs the **same** `verify-harness.sh` humans run locally — local and CI checks never drift.
- The label taxonomy these forms use is documented in [`../.agents/workflows/github-issues.md`](../.agents/workflows/github-issues.md).

## epic-sync.yml — Design Notes

GitHub's built-in `closes #N` keyword only fires on merges to the **default branch**; this Action fills that gap for sub-PRs targeting an `epic/*` branch instead of `main`. Implementation mechanics (integer-only extraction, per-issue error handling, job guard) are documented in the inline comments of `workflows/epic-sync.yml`.

## Runtime Adapters

Runtime adapter directories (`.codex/`, `.claude/`) are thin wrappers — no workflow content is duplicated in them; everything points back to `.agents/`. See [`.agents/context/runtimes.md`](../.agents/context/runtimes.md) for the full portability model.

## Agent Rules

- Keep issue forms valid YAML — `verify-harness.sh` parses every file under `ISSUE_TEMPLATE/` and `workflows/`.
- CI must keep running `verify-harness.sh` as its source of truth. Add steps around it; do not replace it with inline checks (see decision 2026-06-03).
- Pin actions to major-version tags unless the threat model requires SHA pinning.
- Never add secrets to workflow files; use repository secrets and never echo them.
- Do not weaken `permissions:` in `ci.yml` beyond what a step needs.

## Common Workflows

- **Edit CI safely:** change `ci.yml`, then run `bash ../scripts/verify-harness.sh` locally and confirm the YAML still parses. Diagnose failures with `/ci-debug`.
- **Add an issue form:** copy an existing `.yml`, keep labels consistent with the taxonomy, validate locally.

## Commands

`/ci-debug`, `/issue-plan`, `/issue-breakdown`. See [`../.agents/context/slash-commands.md`](../.agents/context/slash-commands.md).

## Skills

[`test-debugging`](../.claude/skills/test-debugging/SKILL.md) (CI failures), [`github-issue-planning`](../.claude/skills/github-issue-planning/SKILL.md).

## Testing / Validation

`bash ../scripts/verify-harness.sh` validates issue-form and workflow YAML and that the CI references the verify script. `shellcheck` covers shell, not YAML.

## Known Risks

- A malformed issue-form `.yml` breaks the issue chooser on GitHub but may pass a loose local check — always validate YAML.
- Changing CI triggers/branches can silently stop verification on PRs.

## Recent Decisions

- 2026-06-03 — CI runs `verify-harness.sh` as the single source of verification truth. See [`../.agents/logs/decisions.md`](../.agents/logs/decisions.md).

## Update Rules

When you add/remove an issue form or a label, update [`../.agents/workflows/github-issues.md`](../.agents/workflows/github-issues.md) and re-run `verify-harness.sh`. When you change CI, note it in [`../.agents/logs/changelog.md`](../.agents/logs/changelog.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
