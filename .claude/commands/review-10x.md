---
description: Strict 10/10 review gate with the full review-result block
argument-hint: "[target]"
model: opus
---

# /review-10x

> Run the strict review gate: in autonomous-loop mode, only 10/10 with zero Critical/Major issues earns PASS.

## Purpose

Use this command as the mandatory final gate before any non-trivial change is considered done. It runs a full, adversarial rubric pass against the target change, scores every dimension, applies strict-mode verdict rules, and emits a complete Review Result block. A REVISE or BLOCK verdict includes exact required fixes so the next loop iteration is unambiguous.

Target: **$ARGUMENTS**

## Usage

`/review-10x <target>` — where `<target>` is a PR number, a branch name, a commit range, or a list of changed files. Example: `/review-10x feat/add-auth-module`.

If `$ARGUMENTS` is empty, infer the target from the current branch and staged/unstaged diff; if that is also ambiguous, stop and ask before proceeding.

## Parameters

- `$ARGUMENTS` (optional) — the PR number, branch, commit range, or file list to review. Defaults to the current working diff when omitted and unambiguous.

## Preconditions

- The change under review exists and is readable (diff, PR, or file tree accessible).
- The acceptance criteria for the change are available — from the linked GH issue, sprint contract in [`.agents/logs/progress.md`](../../.agents/logs/progress.md), or the PR description.
- The implementer's verification evidence is present or its absence is noted — do not assume a check passed because it was claimed.

## Procedure

1. **Read the change and the contract.** Fetch the full diff or file set identified by `$ARGUMENTS`. Read the acceptance criteria from the sprint contract or linked issue. If acceptance criteria are missing, that is itself a Major issue — flag it now and continue. Do not read only the summary — inspect every changed file.

2. **Inspect verification evidence.** Locate the verification artifacts the implementer submitted: lint output, typecheck output, test results, build output, screenshots or demo artifacts, git-diff-cached review (no secrets staged), and the no-LLM-attribution grep. Mark each as Present, Absent, or Unverifiable in the Evidence Checked checklist. Do not treat a claim as evidence — if the output is not shown, mark it Absent.

3. **Score every rubric dimension adversarially.** Work through each dimension in [`evaluator-rubric.md`](../../evaluator-rubric.md) and assign a score of 1–10. Be adversarial: actively hunt for the missing edge case, the silent regression, the unverified claim, the security hole. For each deduction, name the file and the concrete reason. Dimensions: Correctness, Verification quality, Architecture fit, Simplicity, Maintainability, Test coverage, UX/demo quality, Frontend design quality, Accessibility, Performance impact, Security/privacy risk, Documentation quality, Handover quality, Worktree hygiene, GitHub issue/PR hygiene, No LLM attribution, Secret safety. Mark dimensions N/A only when they genuinely do not apply (e.g., Frontend design for a backend-only change).

4. **Categorize every finding.** Label each finding Critical (must fix before PASS), Major (must fix before PASS), Minor (fix preferred, not blocking), or Nit (optional polish). Every Critical/Major finding must cite a concrete location (file + line or reproduction step) — no vague claims.

5. **Apply strict-mode verdict rules.** Compute the overall verdict: `Score 10/10 + Critical issues: 0 + Major issues: 0 + Evidence present → PASS`. Any other combination is `REVISE` (issues are fixable in-session) or `BLOCK` (fundamentally wrong, unsafe, or requires out-of-scope work). Do not issue PASS at 9/10 in an autonomous loop — strict mode forbids it.

6. **Emit the Review Result block.** Fill in the full block (see Output) with today's date and the task name. If the verdict is REVISE or BLOCK, enumerate each required fix with enough specificity that the next loop iteration can address it without ambiguity. Record the block in [`.agents/logs/verification.md`](../../.agents/logs/verification.md) or as a PR comment. Update the sprint contract status to reflect the verdict.

## Stop Conditions

- **Success (PASS):** Score is 10/10, zero Critical/Major issues, all evidence present, Review Result block recorded. Signal done to the calling loop.
- **REVISE:** Score is below 10/10 or Minor/Major/Critical issues exist but are fixable. Return the required-fixes list to the caller; do not mark the task done.
- **BLOCK:** Change is fundamentally wrong, introduces a security or data regression, or cannot reach PASS without out-of-scope redesign. Stop the loop immediately, document the reason, and create a follow-up issue.
- **Max iterations reached:** If the calling loop has exhausted its iteration cap (see [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)) and Critical/Major issues remain, do not ship — document them and file follow-up issues.

## Safety

- Never issue PASS when Critical or Major issues are open, regardless of pressure to finish.
- Never weaken the rubric to make a change pass — if a dimension cannot be scored, that is itself a finding.
- Do not commit, push, or merge as part of this command — reviewing is read-only.
- No AI/LLM attribution in any review comment, PR body, or log entry.
- Never print, log, or echo secrets found in the diff — report their presence as a Critical finding and stop.
- Confirm before posting a BLOCK verdict to a live PR in case the implementer is still in-session and can fix immediately.

## Output

Emit a filled Review Result block:

```
## Review Result — YYYY-MM-DD — [Task Name]

### Score
X / 10

### Verdict
PASS | REVISE | BLOCK

### Critical Issues (must fix before PASS)
- (none) | - <file>:<line> — description

### Major Issues (must fix before PASS)
- (none) | - <file>:<line> — description

### Minor Issues (fix preferred but not blocking)
- (none) | - description

### Nit Issues (optional polish)
- (none) | - description

### Evidence Checked
- [ ] Lint output
- [ ] Typecheck output
- [ ] Test results
- [ ] Build output
- [ ] Screenshot / GIF / demo artifact
- [ ] No secrets staged (git diff --cached reviewed)
- [ ] No LLM attribution (grep reviewed)

### Required Follow-up
- (none) | - issue #N or task description
```

Record the block in [`.agents/logs/verification.md`](../../.agents/logs/verification.md). If REVISE or BLOCK, also surface it to the calling loop as the list of exact required fixes.

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/review-pr`, `/architecture-review`, `/review-loop`, `/gated-orchestration`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
