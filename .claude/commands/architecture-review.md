---
description: Architecture-fit review against harness conventions
argument-hint: "[scope]"
model: opus
---

# /architecture-review

> Check a change for architectural fit: does it follow existing conventions, stay extensible, and avoid needless complexity or duplication.

## Purpose

Use this after implementing a non-trivial change — or before merging — to verify the change belongs where it landed, follows established patterns, and does not introduce unwarranted abstractions, hidden duplication, or accidental rigidity. Focuses strictly on the **architecture dimension** of the review rubric.

Scope: **$ARGUMENTS**

## Usage

`/architecture-review [scope]` — e.g. `/architecture-review src/modules/payments` or `/architecture-review` (reviews the current diff). If `$ARGUMENTS` is empty, derive scope from the staged or recent diff.

## Preconditions

- Repo state is known (`git status` and `git diff` have been read).
- On a feature branch or worktree, not the default branch.
- Architecture and conventions context docs are accessible: [`.agents/context/architecture.md`](../../.agents/context/architecture.md) and [`.agents/context/conventions.md`](../../.agents/context/conventions.md).

## Procedure

Load architecture and conventions context, identify the change surface, assess fit/extensibility/simplicity, categorize findings, score. Full procedure: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) per [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Stop Conditions

All findings categorized and a score assigned; stop and ask if architecture context is missing or scope is meaninglessly ambiguous; BLOCK immediately on Critical finding. See [`evaluator-rubric.md`](../../evaluator-rubric.md).

## Safety

Read-only — do not modify any files during this review. Never echo secrets; flag their presence as Critical without reproducing the value.

## Output

Emits an Architecture Review block (score, verdict, findings table, Architecture Fit / Extensibility / Simplicity sections, Recommended Actions). Scoring dimensions, severity levels (Critical/Major/Minor/Nit), verdict rules (PASS/REVISE/BLOCK), and block template: [`evaluator-rubric.md`](../../evaluator-rubric.md). Full review workflow: [`.agents/workflows/review.md`](../../.agents/workflows/review.md). Skill procedure: [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md)
- **Commands:** `/review-10x`, `/security-review`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
