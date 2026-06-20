---
description: Pre-release checklist: verify, changelog, clean state
---

# /release-check

> Run the pre-release gate: full verification, changelog accuracy, clean-state checklist, and compliance (no secrets/attribution) before any tag or publish action.

## Purpose

Use this before tagging a release, cutting a version bump PR, or publishing a package. It enforces the harness's release gate: all verification commands pass, the changelog is accurate and up to date, no secrets are staged, and no AI/LLM attribution appears in any artifact. The command emits a go/no-go summary with evidence so the release decision is auditable.

## Usage

`/release-check` — no arguments. Run from the release branch or worktree that represents the version being shipped.

## Parameters

None.

## Preconditions

- You are on the release branch or worktree (not `main`/`master`), or have explicit approval to run on a trunk branch.
- `verify-harness.sh` is executable (if it exists).
- The project verification commands are documented in [`.agents/context/commands.md`](../../.agents/context/commands.md).
- A changelog file exists (e.g. `CHANGELOG.md`, `RELEASES.md`, or equivalent) at the project root.
- `git status` and `git diff --staged` are available to inspect staged state.

## Procedure

1. **Run the harness self-check.** If `verify-harness.sh` is present at the project root, execute it and capture full output. Record pass/fail for each check it reports. If it is absent, note that and continue.

2. **Run project verification commands.** Execute all commands listed in [`.agents/context/commands.md`](../../.agents/context/commands.md) that apply to this change type (lint, typecheck, unit tests, integration tests, build). Capture the exit code and tail output for each. A single command failure is a blocker — document which command failed, the error, and stop the release gate with `NO-GO`.

3. **Confirm changelog accuracy.** Open the changelog file. Verify that:
   - The unreleased or pending version section exists and matches the version being shipped.
   - Every significant change in `git log` since the last tag has a corresponding entry (at minimum: breaking changes, new features, notable fixes).
   - No placeholder text (e.g. `TODO`, `TBD`, `<!-- ... -->`) remains in the release section.
   If any item is missing or inaccurate, update the changelog before proceeding; treat an incomplete changelog as a blocker.

4. **Run the clean-state checklist.** Confirm all of the following:
   - `git status` shows no untracked or unstaged files that belong in the release.
   - `git diff --staged` shows only intentional changes (changelog bump, version file).
   - No merge conflicts are present.
   - The branch is up to date with its upstream (run `git fetch --dry-run` or equivalent to check).
   - No `console.log`, `debugger`, `TODO`, or `FIXME` comments were introduced in this release's diff (grep the diff; report findings, but treat only `TODO`/`FIXME` in shipped code as a blocker — `debugger` is always a blocker).

5. **Confirm no secrets are staged and no AI attribution exists.** Scan staged changes and the changelog for:
   - Secret patterns: API keys, tokens, passwords, private keys, `.env` values (grep for common patterns: `sk-`, `ghp_`, `-----BEGIN`, `password=`, `secret=`). Any match is an immediate `NO-GO` blocker.
   - AI/LLM attribution: scan commit messages in the release range and PR descriptions for any assistant or model credit — author/co-author trailers naming an AI tool, "made with"-style assistant notes, or model/tool-name sign-offs. Any match is a `NO-GO` blocker — strip it and re-verify.

6. **Emit the go/no-go summary** (see Output below). If all checks pass, verdict is `GO`. If any blocker is present, verdict is `NO-GO` with the blocking item(s) listed and remediation notes.

## Stop Conditions

- **GO:** All verification commands pass, changelog is accurate, clean-state checklist passes, no secrets, no AI attribution. Safe to tag and publish.
- **NO-GO (stop immediately):** Any verification command fails; secrets found in staged changes; AI attribution found in commits or descriptions; changelog is absent or has placeholder text for the release version.
- **Escalate / ask:** The version being released is unclear or in conflict; a remediation step would require a force-push or history rewrite; destructive or outward-facing publish actions require explicit approval before running.

## Safety

- Never tag, publish, or push a version without a `GO` verdict and explicit human approval.
- Never echo or log secret values — report only that a pattern was found and where.
- No AI/LLM attribution in any commit, PR, changelog entry, or release note.
- Confirm before any outward-facing action (tag push, package publish, GitHub release creation).

## Output

Emit a release-check report:

```md
## Release Check — {{VERSION}}

### Verification
| Command | Result |
|---|---|
| verify-harness.sh | PASS / FAIL / ABSENT |
| <lint command> | PASS / FAIL |
| <typecheck command> | PASS / FAIL |
| <test command> | PASS / FAIL |
| <build command> | PASS / FAIL |

### Changelog
- Version section present: YES / NO
- All notable changes reflected: YES / NO — <gap notes if any>
- No placeholder text: YES / NO

### Clean State
- Working tree clean: YES / NO
- No unintended staged changes: YES / NO
- Branch up to date with upstream: YES / NO
- No debug artifacts in diff: YES / NO

### Compliance
- No secrets in staged changes: YES / NO
- No AI/LLM attribution: YES / NO

---
Verdict: GO | NO-GO
Blockers: <list, or "none">
Next step: <tag + publish | fix blockers then re-run /release-check>
```

## Related

- **Skills:** `release-readiness`
- **Workflows:** [`release.md`](../../.agents/workflows/release.md)
- **Commands:** `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
