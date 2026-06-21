# Pull Request

## Summary

<!-- FILL: 2–4 bullet points describing what this PR does and why. -->

-
-

## Linked Issue

<!-- Link the issue this PR resolves. Use auto-closing keywords where appropriate. -->

Closes #<!-- issue number -->

> If the issue is already closed, reference it instead: Related to #<number>

## Changes

<!-- FILL: List the key files/modules changed and what changed in each. -->

| Area | Change |
|------|--------|
| `path/to/file` | Description of change |

## Verification Evidence

<!-- Run the relevant commands and paste output here. Do not leave this blank unless you explain why. -->

```
# Commands run and their results
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}}
{{BUILD_CMD}}
```

<details>
<summary>Output</summary>

```
<!-- paste command output here -->
```

</details>

> TEMPLATE NOTE: Replace command placeholders with the actual project commands discovered in `.agents/context/commands.md`.

## Demo / Evidence

<!-- Attach screenshots, GIFs, videos, or CLI output that show the feature or fix working.
     Store artifacts in .agents/artifacts/ when appropriate. -->

<!-- FILL: drag-and-drop image/GIF here, or link to artifact -->

_No demo captured — reason: <!-- explain if no evidence exists -->_

## Reviewer Score & Verdict

<!-- To be filled in by the reviewer during the review loop. -->

| Field | Value |
|-------|-------|
| Score | /10 |
| Verdict | PASS / REVISE / BLOCK |
| Critical issues | |
| Major issues | |
| Minor / Nit issues | |
| Evidence checked | |

> A PR should not be merged with Critical or Major issues unresolved.

## Worktree / Branch

<!-- Describe the worktree used for this PR, if applicable. -->

- Branch: `<!-- branch name -->`
- Worktree path: `<!-- .agents/worktrees/... or N/A -->`
- Env files: `<!-- copied / not needed / missing — explain -->`

## Checklist

- [ ] No secrets are staged or included in this PR
- [ ] No AI/LLM attribution anywhere (commits, code, docs, PR description)
- [ ] Docs or inline comments updated near changed code (if relevant)
- [ ] `.agents/logs/changelog.md` updated
- [ ] `claude-progress.md` and `.agents/logs/progress.md` updated
- [ ] `.agents/logs/handover.md` updated with compact handover
- [ ] `feature_list.json` updated (status, evidence, github_issue)
- [ ] Clean state confirmed (no unintended files staged, no leftover debug code)
- [ ] Verification commands ran (or clearly justified why they could not)
- [ ] Reviewer score and verdict recorded above (for non-trivial PRs)
- [ ] Related GitHub issue updated or linked
