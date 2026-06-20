---
description: Review a PR diff against the evaluator rubric
argument-hint: "[pr-number]"
model: opus
---

# /review-pr

> Independently review a pull request against the evaluator rubric and emit a scored verdict with categorized findings.

## Purpose

Use this command to run a disciplined, rubric-driven code review on a pull request. It fetches the full PR diff, scores each evaluator dimension, categorizes all findings by severity, and produces a Review Result block with a clear PASS / REVISE / BLOCK verdict. The review is independent — it does not assume the session context that produced the PR.

PR to review: **$ARGUMENTS**

## Usage

`/review-pr <pr-number>` — e.g. `/review-pr 42`.

Omit the PR number to review the PR associated with the current branch.

## Parameters

- `$ARGUMENTS` (optional) — the pull request number. If omitted, infer from `gh pr view` on the current branch. If no PR can be resolved, stop and ask.

## Preconditions

- `gh` is authenticated (`gh auth status` passes).
- The repository has a PR matching `$ARGUMENTS` or the current branch has an open PR.
- [`../../evaluator-rubric.md`](../../evaluator-rubric.md) is present and readable.
- The acceptance criteria for this PR are either embedded in the PR description or locatable via the linked issue.

## Procedure

1. **Resolve the PR.** Run `gh pr view $ARGUMENTS --json number,title,body,baseRefName,headRefName,url` to confirm the PR exists and capture its metadata. If `$ARGUMENTS` is empty, run `gh pr view` on the current branch. Surface the PR title, URL, base branch, and any linked issue numbers.

2. **Fetch the diff and acceptance criteria.** Run `gh pr diff $ARGUMENTS` to obtain the full unified diff. Extract acceptance criteria from the PR body or the linked issue (`gh issue view <n>`). If no acceptance criteria are found, note the gap as a finding and proceed using the PR description as the intent statement.

3. **Run the opus-code-review procedure.** Apply the [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) skill end-to-end following the [`../../.agents/workflows/review.md`](../../.agents/workflows/review.md) workflow:
   - Score each rubric dimension from [`../../evaluator-rubric.md`](../../evaluator-rubric.md) individually (correctness, security, test coverage, code quality, performance, observability, documentation, acceptance-criteria coverage).
   - For each dimension, record the score (1–10) and the evidence or rationale.
   - Categorize every finding as **Critical**, **Major**, **Minor**, or **Nit** per the rubric severity definitions.

4. **Compute the overall score and verdict.**
   - Overall score = lowest dimension score (or weighted composite per the rubric — match whatever the rubric specifies).
   - Verdict rules:
     - `PASS` — overall score 10/10, zero Critical findings, zero Major findings, evidence captured.
     - `REVISE` — one or more Major findings, or overall score < 10 with no Criticals.
     - `BLOCK` — one or more Critical findings, or a security / correctness failure that cannot be deferred.
   - Record the verdict and the decisive factor.

5. **Emit the Review Result block.** Format and output the block as specified in [## Output](#output) below. Do not truncate findings — list every one with its category, location (file + line if available), and a concrete recommended fix.

6. **Post to the PR if appropriate.** If the verdict is `REVISE` or `BLOCK`, post the Review Result block as a PR comment via `gh pr comment $ARGUMENTS --body "$(cat <<'EOF' ... EOF)"`. If the verdict is `PASS` and the diff is non-trivial, post a brief approval comment. Skip posting only when instructed otherwise.

## Stop Conditions

- **Success:** Review Result block emitted, verdict recorded, comment posted (if appropriate).
- **Stop and ask:** PR cannot be resolved; `gh` auth fails; the evaluator rubric is missing or unreadable.
- **Block and escalate:** A Critical security or correctness finding is found — emit `BLOCK`, post the comment, and stop. Do not attempt to fix within this command; use `/security-review` or `/gated-orchestration` for remediation.

## Safety

- Never commit, push, or merge on behalf of the reviewer — this command is read-and-report only.
- Never echo secret values found in the diff; redact them in findings and flag as Critical.
- No AI/LLM attribution in any PR comment, commit, or finding description.
- Do not approve a PR that has unresolved Critical or Major findings, regardless of other signals.

## Output

Emit this block verbatim (fill in each field):

```md
## Review Result — PR #<number>: <title>

**URL:** <pr-url>
**Base → Head:** <base> → <head>
**Reviewed against:** evaluator-rubric.md

### Dimension Scores

| Dimension | Score | Notes |
|---|---|---|
| Correctness | /10 | |
| Security | /10 | |
| Test coverage | /10 | |
| Code quality | /10 | |
| Performance | /10 | |
| Observability | /10 | |
| Documentation | /10 | |
| Acceptance criteria | /10 | |

**Overall:** /10 — Verdict: PASS | REVISE | BLOCK

### Findings

#### Critical
- [ ] <file>:<line> — <description> — **Fix:** <recommendation>

#### Major
- [ ] <file>:<line> — <description> — **Fix:** <recommendation>

#### Minor
- [ ] <file>:<line> — <description> — **Fix:** <recommendation>

#### Nit
- [ ] <file>:<line> — <description>

### Evidence
<verification commands run and their output, or "none — static diff review only">

### Decision
<Decisive factor for the verdict; what must change before PASS.>
```

If there are no findings in a severity category, write `_none_` under that heading.

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md)
- **Commands:** `/review-10x`, `/security-review`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
