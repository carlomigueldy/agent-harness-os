---
description: Reconcile feature_list.json against live GitHub Issue state, surface drift, and cautiously repair it with --fix.
argument-hint: "[--fix] [--epic <issue-number>]"
---

# /sync-ledger

> Keep feature_list.json in sync with GitHub Issue state; never fabricate evidence.

## Purpose

Use this after PR merges, issue closures, or at session start/end to detect drift between `feature_list.json` and the live state of the linked GitHub Issues. Wraps `scripts/sync-ledger.sh`. Run report mode first; review `[DRIFT]` findings; then decide whether to apply `--fix` or resolve manually.

## Usage

`/sync-ledger [--fix] [--epic <issue-number>]`

- No arguments: report drift only, no changes.
- `--fix`: apply cautious updates (flips `status` to `passing` only when the issue is CLOSED **and** `evidence` is non-empty).
- `--epic <N>`: list all sub-issues referenced in epic #N and their current GitHub state.

## Preconditions

- `feature_list.json` exists at the repo root.
- `python3` is available.
- For GitHub issue queries: `gh` installed and authenticated. Gracefully degrades if unavailable.
- Running from the repo root (or a worktree that has `feature_list.json`).

## Procedure

Run `sync-ledger.sh` in report mode, classify each `[DRIFT]` line by safe-to-fix vs. manual action needed, optionally re-run with `--fix`, resolve remaining drift manually. Full drift classification: [`scripts/sync-ledger.sh`](../../scripts/sync-ledger.sh).

## Stop Conditions

Done: all `[DRIFT]` items resolved or escalated, all checked features `[OK]`, `feature_list.json` is valid JSON. Stop and ask: drift requires human judgment (closed issue with no evidence and verification cannot run). Stop and notice: `gh` unavailable — report SKIP items and exit cleanly.

## Safety

- Never fabricate evidence. If an issue is closed but `evidence` is empty, leave `status` unchanged.
- Never weaken a `passing` status without explicit confirmation that the feature regressed.
- `scripts/sync-ledger.sh` is read-only in report mode; `--fix` writes only to `feature_list.json`.

## Output

Emits a Ledger Sync Report (mode, items checked, OK count, drift list with resolutions, fixes applied, items requiring manual action, JSON validation result). Full drift classification and fix rules: procedure in [`scripts/sync-ledger.sh`](../../scripts/sync-ledger.sh). Epic-delivery context: [`.agents/workflows/epic-delivery.md`](../../.agents/workflows/epic-delivery.md).

## Related

- **Script:** [`scripts/sync-ledger.sh`](../../scripts/sync-ledger.sh)
- **Workflows:** [`epic-delivery.md`](../../.agents/workflows/epic-delivery.md), [`github-issues.md`](../../.agents/workflows/github-issues.md)
- **Skills:** [`github-issue-planning`](../../.claude/skills/github-issue-planning/SKILL.md)
- **Commands:** `/issue-plan`, `/issue-breakdown`, `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
