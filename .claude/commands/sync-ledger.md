---
description: Reconcile feature_list.json against live GitHub Issue state, surface drift, and cautiously repair it with --fix.
argument-hint: "[--fix] [--epic <issue-number>]"
---

# /sync-ledger

> Keep feature_list.json in sync with GitHub Issue state; never fabricate evidence.

## Purpose

Use this command after PR merges, issue closures, or at session start/end to detect drift between `feature_list.json` and the live state of the linked GitHub Issues. It wraps `scripts/sync-ledger.sh`, interprets the output, and optionally updates the ledger — but only in ways that are safe and evidence-backed.

Run it in report mode first. Review the `[DRIFT]` findings. Then decide whether to apply `--fix` or resolve manually (e.g., add evidence before flipping a feature to `passing`).

## Usage

`/sync-ledger [--fix] [--epic <issue-number>]`

- No arguments: report drift only, no changes.
- `--fix`: apply cautious updates (flips `status` to `passing` only when the issue is CLOSED **and** `evidence` is non-empty).
- `--epic <N>`: list all sub-issues referenced in epic #N and their current GitHub state.

## Parameters

- `--fix` (optional) — enable cautious ledger updates. Safe by default.
- `--epic <N>` (optional) — epic issue number (with or without `#`). Prints sub-issue state table. Requires `gh`.

## Preconditions

- `feature_list.json` exists at the repo root.
- `python3` is available.
- For GitHub issue queries: `gh` is installed and authenticated (`gh auth login`). Gracefully degrades with a notice if not available.
- Running from the repo root (or any worktree that has `feature_list.json`).

## Procedure

1. **Run in report mode.** Execute `bash scripts/sync-ledger.sh` from the repo root. Read and interpret all output lines.

2. **Classify findings.** For each `[DRIFT]` line:
   - `issue CLOSED + evidence present → should be 'passing'`: safe to fix with `--fix`.
   - `issue CLOSED but evidence=[]`: do NOT flip status yet — evidence is missing. Record what evidence is needed and surface it to the operator.
   - `status=passing but issue OPEN`: investigate — either close the issue (if work is truly done and evidence exists) or revert `status` to the correct in-progress state.
   - `in_progress but github_issue is null`: open a GH issue, update `github_issue` in the ledger.

3. **Decide on --fix.** If all safe-to-flip drifts are due to closed issues with evidence, re-run with `--fix`:
   ```
   bash scripts/sync-ledger.sh --fix
   ```
   Confirm the `[FIX]` lines match expectations. Verify the JSON is still valid.

4. **Resolve remaining drift manually.** For any drift `--fix` does not handle:
   - Add evidence to `feature_list.json` before marking `passing`.
   - Open missing GH issues and set `github_issue`.
   - Close stale open issues or update `status` as appropriate.
   - Never invent evidence — if verification cannot run, document why and leave `status` at its current value.

5. **Report findings.** Emit a summary: number of items checked, drift count, fixes applied, and any items requiring manual action. Reference `feature_list.json` as the source of record.

## Stop Conditions

- **Done:** All `[DRIFT]` items resolved (either fixed or escalated with a clear action item), `[OK]` for all checked features, and `feature_list.json` is valid JSON.
- **Stop and ask:** A `[DRIFT]` item requires human judgment — e.g., the issue is closed but no evidence exists and verification cannot run.
- **Stop and notice:** `gh` is unavailable — report the SKIP items and exit cleanly. Do not treat this as a failure.

## Safety

- Never fabricate evidence. If an issue is closed but `evidence` is empty, leave `status` unchanged and surface the gap.
- Never weaken a `passing` status without explicit confirmation that the feature regressed.
- Never print, log, or commit secrets or `.env` values.
- `scripts/sync-ledger.sh` is read-only in report mode; `--fix` writes only to `feature_list.json`. No other files are modified.
- This command does not push to GitHub, close issues, or open PRs — those are done by `epic-sync.yml` automatically or by the agent explicitly.

## Output

Emit a **Ledger Sync Report**:

```
## Ledger Sync Report
- Ledger: feature_list.json
- Mode: REPORT | FIX
- Items checked: N
- OK: N
- Drift found: N
  - [list each drift item and its resolution or required action]
- Fixes applied: N (or "none")
- Items requiring manual action:
  - [list with required next step]
- Validation: feature_list.json is valid JSON [confirmed / FAILED]
```

## Related

- **Script:** [`scripts/sync-ledger.sh`](../../scripts/sync-ledger.sh)
- **Workflows:** [`../../.agents/workflows/epic-delivery.md`](../../.agents/workflows/epic-delivery.md), [`../../.agents/workflows/github-issues.md`](../../.agents/workflows/github-issues.md)
- **Skills:** [`github-issue-planning`](../skills/github-issue-planning/SKILL.md)
- **Commands:** `/issue-plan`, `/issue-breakdown`, `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
