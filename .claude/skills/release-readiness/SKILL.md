---
name: release-readiness
description: Run the pre-release gate: full verification, changelog accuracy, clean-state checklist, no secrets or attribution
---

# Skill: release-readiness

## Purpose

Confirm that a change is ready to release: verification green, changelog accurate, working tree clean, and compliant with no-secrets and no-attribution rules. This is the go/no-go gate that must pass before tagging a version, publishing a release, or merging an epic into `main`/`master`. Full release protocol lives in [`../../../.agents/workflows/release.md`](../../../.agents/workflows/release.md).

## When to Use

- Before tagging or cutting a release (version bump, `git tag`, publish step).
- Before merging an epic branch — run this after the final `/opus-code-review` pass.
- When `/release-check` or `/final-handoff` is invoked as part of a delivery wrap-up.
- Any time you need a single evidence-backed statement that the project is shippable.

## When Not to Use

- Mid-development, before meaningful verification is possible — verification will be incomplete by design; wait until the feature is functionally complete.
- For work that is not heading to a release or a merge into the default branch — use `/opus-code-review` for intermediate review instead.
- When only a subset of modules changed and the full gate is disproportionate — scope the verification to the affected surface and document the decision.

## Inputs

- The branch or diff to gate (branch name, PR number, or explicit file list).
- The changelog entry (or CHANGELOG.md, release notes draft, or equivalent) claiming to describe what ships.
- The project's verification commands from [`.agents/context/commands.md`](../../../.agents/context/commands.md).
- A clean working tree (or a documented, intentional exception).

## Outputs

- A **Go / No-Go Summary** block (see Procedure step 4) recorded in [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md), with evidence attached.
- Any blocking findings listed as required fixes before the gate can flip to Go.

## Procedure

1. **Run the harness verifier and all project verification commands.**
   Execute `bash scripts/verify-harness.sh` (if present) followed by the full verification sequence from [`.agents/context/commands.md`](../../../.agents/context/commands.md): lint, type-check, unit tests, integration tests, build, and any smoke tests. Capture the raw output — do not summarize without evidence. If a command cannot run, document why and note the residual risk.

2. **Audit the changelog for accuracy.**
   Read the changelog entry (or release notes draft) line by line against the actual diff. Confirm every shipped item is listed and no unreleased or reverted change is claimed. Check that the version identifier (semver or date) is consistent with what the code ships. Flag missing entries, stale entries, or version mismatches as blocking — the changelog is the contract with the next session and with users.
   Also confirm the clean-state checklist passes: no uncommitted changes, no debug flags or temporary stubs left in, no TODO/FIXME markers tagged for this release, and no pending migrations that the release depends on.

3. **Scan for secrets and AI/LLM attribution.**
   Run a secrets scan over staged and committed files (e.g., `git diff origin/main...HEAD` piped through a secrets detector, or `grep -rE` for common patterns: API keys, tokens, passwords, connection strings). Confirm no secret value is present in code, config, or docs.
   Separately scan commits in the release range (`git log --oneline origin/main..HEAD`) for any co-author lines or commit-message text attributing the change to an AI, LLM, or automated tool. Both are hard blockers — do not proceed until cleared.

4. **Emit the Go / No-Go Summary.**
   Write and record the following block, populated with real evidence:

   ```
   ## Release Readiness Gate — {{VERSION_OR_BRANCH}}

   Date: {{DATE}}
   Scope: {{BRANCH_OR_PR}}

   ### Verification
   - [ ] verify-harness.sh: PASS / FAIL / SKIPPED (reason)
   - [ ] Lint:              PASS / FAIL
   - [ ] Type-check:        PASS / FAIL
   - [ ] Unit tests:        PASS / FAIL  (N passed, M failed)
   - [ ] Integration tests: PASS / FAIL
   - [ ] Build:             PASS / FAIL
   - [ ] Smoke test:        PASS / FAIL / SKIPPED (reason)

   ### Changelog
   - [ ] All shipped items listed: YES / NO (missing: …)
   - [ ] No unreleased items claimed: YES / NO
   - [ ] Version identifier correct: YES / NO

   ### Clean State
   - [ ] Working tree clean: YES / NO
   - [ ] No debug stubs or temporary TODOs: YES / NO
   - [ ] Pending migrations resolved: YES / NO / N/A

   ### Compliance
   - [ ] No secrets in diff/commits: YES / NO
   - [ ] No AI/LLM attribution in commits: YES / NO

   ### Verdict
   VERDICT: GO / NO-GO
   Blocking findings:
   - (list or "none")
   ```

   `GO` requires every item checked YES/PASS and zero blocking findings. Record the block in [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md) and include the raw command output as an appendix.

## Checks

- Every checklist item has a concrete result — no "assumed", "probably", or empty cells.
- Verification commands were actually run; output is captured, not paraphrased.
- Changelog was compared against the actual diff, not recalled from memory.
- Secrets scan covered all files changed in the release range, not just the last commit.
- No commit in the release range carries AI/LLM attribution in any field.
- `NO-GO` findings are specific, actionable, and assigned an owner or next step.

## Common Failure Modes

- **Skipping verification because it "obviously passes."** Run it. Capture the output. One unrun check invalidates the gate.
- **Changelog written from memory.** Diff the changelog against `git log --oneline` and the PR list. Missing entries surface after release when they shouldn't.
- **Secrets scan limited to the working tree.** Scan the full commit range — a secret committed and then removed from HEAD is still in history and still a blocker.
- **Issuing GO under time pressure with open findings.** Downgrade open findings to Minor or Nit with documented justification, or keep them as blocking. Never close your eyes to a finding.
- **Forgetting clean-state checks on a long-running epic.** Debug flags and temporary stubs accumulate quietly. Make the scan explicit.

## Example Usage

> Before merging `epic/auth-overhaul` → `main`: run `bash scripts/verify-harness.sh` (all checks pass), confirm the CHANGELOG entry lists the three new endpoints and removed legacy route, grep for secrets (none found), scan commit log for attribution (none found), working tree clean. Emit `VERDICT: GO` in `verification.md` with the captured output appended.

> Counter-example: integration tests fail on one edge case, and the changelog lists a feature that was reverted. Gate emits `VERDICT: NO-GO` with two blocking findings. Implementation agent fixes both; gate re-runs and flips to `GO`.

When wrapping up the release, hand off cleanly using the `handoff-writing` skill to produce the session handover before tearing down the worktree.

## Related Commands

`/release-check`, `/final-handoff`

## Maintenance Notes

- Keep the checklist in step 4 in sync with [`../../../.agents/workflows/release.md`](../../../.agents/workflows/release.md). If the release workflow adds a new gate (e.g., a migration dry-run or a security scan step), add a row to the checklist here.
- If the project defines custom verification commands in [`.agents/context/commands.md`](../../../.agents/context/commands.md), name them explicitly in step 1 rather than relying on the generic description.
- The secrets scan command should be updated if the project adopts a dedicated secrets-scanning tool (e.g., `gitleaks`, `trufflehog`).
- Review this skill whenever the evaluator rubric ([`../../../evaluator-rubric.md`](../../../evaluator-rubric.md)) adds a new compliance dimension.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
