---
description: Review a PR diff against the evaluator rubric
argument-hint: "[pr-number]"
model: opus
---

# /review-pr

> Independently review a pull request against the evaluator rubric and emit a scored verdict with categorized findings.

## Purpose

Use this to run a rubric-driven code review on a pull request. Fetches the full PR diff, scores each evaluator dimension, categorizes findings by severity, and produces a Review Result block with a PASS / REVISE / BLOCK verdict. The review is independent — it does not assume the session context that produced the PR.

PR to review: **$ARGUMENTS**

## Usage

`/review-pr <pr-number>` — e.g. `/review-pr 42`. Omit to review the PR on the current branch.

## Preconditions

- `gh` is authenticated (`gh auth status` passes).
- The repository has a PR matching `$ARGUMENTS` or the current branch has an open PR.
- [`evaluator-rubric.md`](../../evaluator-rubric.md) is present and readable.
- Acceptance criteria are in the PR description or linked issue.

## Procedure

Resolve the PR, fetch the full diff and acceptance criteria, apply [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) per [`.agents/workflows/review.md`](../../.agents/workflows/review.md), compute verdict, post comment on REVISE/BLOCK.

## Stop Conditions

Review Result block emitted and comment posted; BLOCK and escalate on Critical security/correctness finding. See [`evaluator-rubric.md`](../../evaluator-rubric.md).

## Safety

Never commit, push, or merge from this command — read-and-report only. Never echo secrets found in the diff; redact and flag as Critical.

## Output

Emits a Review Result block with per-dimension scores and posts it as a PR comment on REVISE/BLOCK. Scoring dimensions, severity levels, verdict rules, and block template: [`evaluator-rubric.md`](../../evaluator-rubric.md). Full review workflow: [`.agents/workflows/review.md`](../../.agents/workflows/review.md). Skill procedure: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md)
- **Commands:** `/review-10x`, `/security-review`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
