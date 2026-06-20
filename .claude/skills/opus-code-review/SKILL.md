---
name: opus-code-review
description: Run a strict 10/10 Opus-led review of a change against the evaluator rubric, emitting a scored verdict (PASS/REVISE/BLOCK) with Critical/Major/Minor/Nit findings
---

# Skill: opus-code-review

## Purpose

Perform a rigorous, adversarial code/change review against [`../../../evaluator-rubric.md`](../../../evaluator-rubric.md) and return a scored verdict. In strict autonomous-loop mode, only 10/10 with zero Critical/Major issues earns `PASS`. This is the review gate the harness uses before any non-trivial change is considered done.

## When to Use

- Reviewing a PR, a diff, or a unit of work produced by an implementation agent.
- The final gate of `/gated-orchestration`, `/review-loop`, `/review-pr`, and `/review-10x`.
- Any time work is about to be marked "done" and you want an independent, evidence-based check.

## When Not to Use

- Trivial, mechanical edits (formatting, a typo fix) where a full rubric pass is overkill — a quick sanity check suffices.
- When you are the implementer and cannot review your own work independently *and* a separate reviewer is available — prefer the independent reviewer.
- For security-specific depth, pair with the [`security-review`](../security-review/SKILL.md) skill rather than relying on the rubric's single security line.

## Inputs

- The change under review: a diff, a PR number, a branch, or a set of files.
- The acceptance criteria (from the sprint contract or issue) the change must satisfy.
- The verification evidence the implementer captured (test output, screenshots, CLI logs).

## Outputs

- A filled **Review Result** block (see Output) recorded in [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md) or the PR, with score, verdict, and categorized findings.

## Procedure

1. **Establish the contract.** Read the acceptance criteria and the diff. If criteria are missing, that is itself a Major issue — flag it.
2. **Read the actual change**, not the description. Inspect every changed file. Run or re-derive the verification where feasible; do not trust claims without evidence.
3. **Score each rubric dimension 1–10** from [`../../../evaluator-rubric.md`](../../../evaluator-rubric.md): correctness, verification quality, architecture fit, simplicity, maintainability, tests, UX/demo, security, docs, handover, worktree hygiene, issue/PR hygiene, no-attribution, secret safety.
4. **Categorize findings** as Critical / Major / Minor / Nit. Be adversarial: actively try to find the bug, the missing edge case, the unverified claim.
5. **Compute the verdict.** 10/10 + no Critical/Major + evidence present → `PASS`. Otherwise `REVISE` (fixable) or `BLOCK` (fundamentally wrong).
6. **Emit the Review Result block** and record it. If `REVISE`/`BLOCK`, list the exact required fixes so the next loop iteration is unambiguous.

## Checks

- Every Critical/Major finding cites a file and line or a concrete reproduction — no vague claims.
- The verdict math matches the rubric (no `PASS` below 10/10 in strict mode).
- Verification evidence was actually inspected, not assumed.
- No AI/LLM attribution slipped into the change; no secrets staged.

## Common Failure Modes

- **Rubber-stamping** — passing work because it "looks fine" without running checks. Always inspect evidence.
- **Treating agreement as proof** — multiple agents liking a change is not verification.
- **Scope creep in review** — flagging out-of-scope preferences as blocking. Keep Critical/Major tied to correctness, safety, and acceptance criteria.
- **Passing at 9/10** in an autonomous loop — strict mode forbids it.

## Example Usage

> `/review-10x` on a PR that adds a feature: reviewer reads the diff, re-runs the test suite (1 failing edge case → Major), scores 8/10 `REVISE` with one required fix. After the fix, re-review → 10/10 `PASS`, recorded in `verification.md`.

## Related Commands

`/review-10x`, `/review-pr`, `/review-loop`, `/gated-orchestration`, `/security-review`

## Maintenance Notes

Keep the rubric dimensions in step with [`../../../evaluator-rubric.md`](../../../evaluator-rubric.md) and the review gates in [`../../../.agents/workflows/review.md`](../../../.agents/workflows/review.md). If a new dimension is added to the rubric, add it to step 3.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
