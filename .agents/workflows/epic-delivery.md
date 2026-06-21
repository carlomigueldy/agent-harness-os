# Epic-Branch Delivery & Ledger Sync

How to deliver a large body of work across an epic branch, keep sub-issues
closed accurately, and maintain `feature_list.json` as the system-of-record ledger.

---

## The Epic-Branch Model

An **epic** is a large goal that spans multiple scoped tasks. The harness models it as:

```
main (default branch)
  └── epic/<name>         ← the epic integration branch
        ├── feat/<task-a> ← sub-PR for task A (targets epic/<name>)
        ├── feat/<task-b> ← sub-PR for task B (targets epic/<name>)
        └── ...
```

- **Epic issue** — a GitHub Issue created from the [epic template](../../.github/ISSUE_TEMPLATE/epic.yml), tracking the goal, sub-issues, and acceptance criteria.
- **Epic branch** — `epic/<name>`, branched from `main`. This is the integration target for all sub-PRs. It is never merged to `main` until the full epic is verified.
- **Sub-issues** — created from the [epic-subissue template](../../.github/ISSUE_TEMPLATE/epic-subissue.yml), each linked to the parent epic (`#<epic-number>`).
- **Sub-PRs** — one PR per sub-issue, targeting `epic/<name>` (not `main`). Each PR body includes a closing keyword: `Closes #<sub-issue>`.
- **Epic PR** — a single draft PR from `epic/<name>` into `main`, kept open until the full epic passes the acceptance gate and review.

Each sub-issue/sub-PR pair follows the standard worktree workflow. See [worktree-sessions.md](worktree-sessions.md).

---

## Why GitHub Does Not Auto-Close Sub-issues on Epic Merges

GitHub's built-in `closes #N` keyword auto-closes issues **only when a PR merges into the repository's default branch** (usually `main`). When a sub-PR merges into `epic/<name>` instead, GitHub performs no automatic closure — the sub-issue remains open even though the work is done.

This gap silently corrupts issue state: sub-issues appear open when their work has already landed on the epic branch, making the epic dashboard misleading and `feature_list.json` drift from reality.

---

## How `epic-sync.yml` Fills the Gap

[`.github/workflows/epic-sync.yml`](../../.github/workflows/epic-sync.yml) is a GitHub Action that fires on every `pull_request` close event. It is guarded by:

```yaml
if: github.event.pull_request.merged == true
    && startsWith(github.event.pull_request.base.ref, 'epic/')
```

When both conditions are true, the action:

1. Parses the merged PR's body for standard closing keywords (`closes`, `fixes`, `resolves`, and their variants) followed by `#<number>`.
2. Extracts only the integer issue numbers — no content from the PR body is evaluated.
3. Closes each referenced issue via the GitHub API and posts a comment linking the epic PR: `"Closed via epic PR #N merged into epic/<name>."`.
4. Logs but does not fail on missing or already-closed issues, so the merge flow is never blocked.

The action is a no-op for PRs that target `main` or any non-`epic/*` branch.

---

## `feature_list.json` as the Ledger

[`feature_list.json`](../../feature_list.json) is the machine-readable system of record for every feature and its progress. The key binding field is `github_issue`:

```json
{
  "id": "auth-login",
  "status": "in_progress",
  "github_issue": 12,
  "epic": 8,
  "evidence": []
}
```

| Field | Meaning |
|---|---|
| `github_issue` | The GH issue number for this feature/task. **Required** once an issue exists. |
| `epic` | The parent epic issue number, or `null` if this feature is not part of an epic. |
| `status` | `not_started` / `in_progress` / `blocked` / `passing`. |
| `evidence` | Non-empty array of test results, screenshots, CLI output, or links required before `passing`. |

### Status ↔ Issue State contract

| Issue state | Expected `status` | Notes |
|---|---|---|
| OPEN | `not_started` or `in_progress` | |
| CLOSED (no evidence) | `in_progress` or `blocked` | Add evidence first — do not flip to `passing` without it. |
| CLOSED + evidence | `passing` | The only valid path to `passing`. |
| OPEN + `passing` | **Drift** | Verify and either close the issue or revert `status`. |

---

## The Rule: Every Agent Task Bound to a GH Issue Must Set `github_issue`

When an agent task is tracked by a GitHub Issue:

1. Set `github_issue` in `feature_list.json` as soon as the issue is created.
2. If the feature belongs to an epic, set `epic` to the epic issue number.
3. Keep `status` in sync with issue/PR state throughout the task.
4. Populate `evidence` before setting `status: passing` — never fabricate evidence.
5. Run `bash scripts/sync-ledger.sh` or `/sync-ledger` to detect and optionally repair drift.

These rules are enforced by convention and surfaced by the sync tooling. CI does not enforce them — the ledger is a living document that agents and humans maintain together.

---

## Sync Cadence — `/sync-ledger` and `scripts/sync-ledger.sh`

[`scripts/sync-ledger.sh`](../../scripts/sync-ledger.sh) reconciles `feature_list.json` against live GitHub Issue state. It is a **local tool only** — never wired into `verify-harness.sh` or CI.

### When to run it

- At the start of a session (after reading the handover) to spot stale ledger state.
- After a burst of PR merges or issue closures.
- Before writing a session handover, to confirm ledger accuracy.
- When the epic PR is being prepared for the final review gate.

### Modes

```bash
# Report drift only (no changes)
bash scripts/sync-ledger.sh

# Cautiously update feature_list.json
# (flips to "passing" only when issue is CLOSED + evidence is non-empty)
bash scripts/sync-ledger.sh --fix

# List sub-issues for an epic and their current state
bash scripts/sync-ledger.sh --epic 42
```

The `/sync-ledger` slash command wraps this script with an imperative procedure. See [`.claude/commands/sync-ledger.md`](../../.claude/commands/sync-ledger.md).

### Drift categories reported

| Tag | Meaning |
|---|---|
| `[OK]` | Ledger status is consistent with GH issue state. |
| `[DRIFT]` | Mismatch detected — review and resolve. |
| `[WARN]` | Issue could not be read (missing, private, or gh error). |
| `[SKIP]` | gh unavailable or unauthenticated — issue not checked. |
| `[FIX]` | Ledger updated by `--fix` (only safe flips). |

---

## Related

- **GitHub Issues workflow (label taxonomy, PR workflow, closing keywords):** [github-issues.md](github-issues.md)
- **Worktree protocol (branch creation, env files, teardown):** [worktree-sessions.md](worktree-sessions.md)
- **Parallel epic delivery (fan-out, per-lane review, integration verify):** [`.claude/skills/parallel-epic-delivery/SKILL.md`](../../.claude/skills/parallel-epic-delivery/SKILL.md)
- **Sync action:** [`.github/workflows/epic-sync.yml`](../../.github/workflows/epic-sync.yml)
- **Sync script:** [`scripts/sync-ledger.sh`](../../scripts/sync-ledger.sh)
- **Sync command:** [`.claude/commands/sync-ledger.md`](../../.claude/commands/sync-ledger.md)

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
