---
description: "Review-until-pass: score 1-10 until 10/10 PASS (max 10)"
argument-hint: "[target]"
model: opus
---

# /review-loop

> Drive a change to a 10/10 PASS through repeated independent review and fixing of Critical/Major issues.

## Purpose

Use this when a change needs to reach verified, reviewer-quality completion. Runs an independent review against the evaluator rubric, fixes every Critical and Major finding, and re-reviews until 10/10 PASS or the iteration cap. Max **10 iterations**.

Target: **$ARGUMENTS**

## Usage

`/review-loop [target]` — e.g. `/review-loop feat/auth-module` or `/review-loop` (defaults to the current working diff).

## Preconditions

- On a feature branch or worktree, not the default branch.
- The change compiles, lints, and passes available automated checks before the first review iteration.
- [`evaluator-rubric.md`](../../evaluator-rubric.md) has been read and is loaded in context.

## Procedure

Review the target against the full rubric, classify and fix Critical/Major findings, re-verify, repeat. Full procedure: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) per [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Stop Conditions

PASS at 10/10 with zero Critical/Major; CAP_REACHED at 10 iterations; BLOCK if Critical requires design decision or irreversible action. See [`evaluator-rubric.md`](../../evaluator-rubric.md) + [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Never bypass the cap by relabeling Critical issues as Minor. Never commit secrets. Do not weaken auth, validation, or rate limits to resolve a finding.

## Output

Emits one Review Result block per iteration, then a final Loop Summary. Scoring, severity classification, verdict rules (PASS/REVISE/BLOCK), and block template: [`evaluator-rubric.md`](../../evaluator-rubric.md). Loop schema, caps, stop conditions, and safety: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Full review workflow: [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/review-10x`, `/build-loop`, `/gated-orchestration`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
