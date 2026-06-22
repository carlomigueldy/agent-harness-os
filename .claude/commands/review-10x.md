---
description: Strict 10/10 review gate with the full review-result block
argument-hint: "[target]"
model: opus
---

# /review-10x

> Run the strict review gate: in autonomous-loop mode, only 10/10 with zero Critical/Major issues earns PASS.

## Purpose

Use this as the mandatory final gate before any non-trivial change is considered done. Runs a full, adversarial rubric pass, scores every dimension, applies strict-mode verdict rules, and emits a complete Review Result block. REVISE or BLOCK includes exact required fixes so the next loop iteration is unambiguous.

Target: **$ARGUMENTS**

## Usage

`/review-10x <target>` — where `<target>` is a PR number, branch name, commit range, or list of changed files. If `$ARGUMENTS` is empty, infer from the current branch and diff; if ambiguous, ask.

## Preconditions

- The change under review exists and is readable.
- Acceptance criteria are available (linked issue, sprint contract in [`.agents/logs/progress.md`](../../.agents/logs/progress.md), or PR description).
- Implementer's verification evidence is present or its absence is noted.

## Procedure

Read the full diff and contract, inspect verification evidence, score every rubric dimension adversarially, classify findings, apply strict-mode verdict. Full procedure: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) per [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Stop Conditions

PASS at 10/10 with zero Critical/Major and all evidence present; REVISE if fixable; BLOCK if fundamental or security issue. See [`evaluator-rubric.md`](../../evaluator-rubric.md).

## Safety

Never issue PASS with open Critical/Major findings. Never print or log secrets found in the diff. Read-only — no commits or merges from this command.

## Output

Emits a filled Review Result block recorded in [`.agents/logs/verification.md`](../../.agents/logs/verification.md). Scoring dimensions, severity levels (Critical/Major/Minor/Nit), strict-mode verdict rules (PASS/REVISE/BLOCK), and Review Result block template: [`evaluator-rubric.md`](../../evaluator-rubric.md). Full review workflow: [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/review-pr`, `/architecture-review`, `/review-loop`, `/gated-orchestration`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
