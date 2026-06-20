---
description: Architecture-fit review against harness conventions
argument-hint: "[scope]"
model: opus
---

# /architecture-review

> Check a change for architectural fit: does it follow existing conventions, stay extensible, and avoid needless complexity or duplication.

## Purpose

Use this command after implementing a non-trivial change — or before merging — to verify the change belongs where it landed, follows the project's established patterns, and does not introduce unwarranted abstractions, hidden duplication, or accidental rigidity. It focuses strictly on the **architecture dimension** of the review rubric and emits a structured finding block suitable for feeding into `/review-10x` or a PR gate.

Scope: **$ARGUMENTS**

## Usage

`/architecture-review [scope]` — e.g. `/architecture-review src/modules/payments` or `/architecture-review` (reviews the current diff in full).

If `$ARGUMENTS` is empty, derive scope from the staged or recent diff automatically.

## Parameters

- `$ARGUMENTS` (optional) — a path, module name, or brief description of what to review. Defaults to the current working diff.

## Preconditions

- Repo state is known (`git status` and `git diff` have been read).
- You are on a feature branch or worktree, not the default branch.
- The architecture and conventions context docs are accessible (checked in step 1 of Procedure).

## Procedure

1. **Load architecture context.** Read [`../../.agents/context/architecture.md`](../../.agents/context/architecture.md) and [`../../.agents/context/conventions.md`](../../.agents/context/conventions.md) in full. Note the established patterns, module boundaries, naming conventions, and any stated constraints or non-goals. If either file is missing or stale, flag it before continuing.

2. **Identify the change surface.** If `$ARGUMENTS` names a path or module, read those files and the relevant diff. Otherwise, read the full current diff (`git diff HEAD` or staged changes). List every file touched and classify each as: new file, modified file, deleted file, or renamed file.

3. **Assess architectural fit.** For each changed file or subsystem, answer:
   - Does it belong in this layer/module, or is it in the wrong place?
   - Does it follow the naming and structural conventions documented in `conventions.md`?
   - Does it respect the module boundaries and ownership described in `architecture.md`?
   - Does it reuse existing abstractions, or does it re-implement something that already exists?
   - Does it introduce a new abstraction? If so, is it warranted — used in at least two places or eliminating clear duplication? If not, flag it as premature abstraction.

4. **Assess extensibility.** Evaluate whether the change makes future changes easier or harder:
   - Are seams and interfaces clean? Are internals hidden behind them?
   - Are there hard-coded values, tight couplings, or structural choices that will force a rewrite to extend?
   - Does the change preserve or erode existing extension points?

5. **Assess simplicity.** Flag complexity that is not justified by requirements:
   - Unnecessary indirection, over-engineered configuration, or layers that add no isolation value.
   - Duplication that could be consolidated now without significant added risk.
   - Dependencies added for marginal benefit.

6. **Categorize findings.** Use the standard severity scale:

   | Severity | Meaning |
   |---|---|
   | **Critical** | Violates a core architectural constraint; blocks merge. |
   | **Major** | Clear pattern violation or unjustified abstraction; should fix before merge. |
   | **Minor** | Sub-optimal but not harmful; fix or defer with a note. |
   | **Nit** | Style or naming divergence; fix if trivial. |

7. **Score the architecture dimension.** Assign a score from 1–10 based solely on architectural quality (fit, extensibility, simplicity, no duplication). A 10 means the change is indistinguishable from the existing codebase in structure and intent.

8. **Emit the Review Result block** (see Output section).

## Stop Conditions

- **Success:** All findings are categorized, a score is assigned, and the Review Result block is emitted.
- **Stop and ask:** Architecture context docs are missing and cannot be inferred from the codebase; or the scope is ambiguous in a way that would make the review meaningless.
- **Block (Critical finding):** Surface the finding immediately and do not proceed to merge or further delegation without resolution.

## Safety

- Do not modify any files during this review. This command is read-only.
- Never echo secrets found in the diff — flag their presence as a Critical finding without reproducing the value.
- No AI/LLM attribution in any output, comment, or issue created from findings.
- Do not conflate architecture findings with functional correctness bugs — those belong in `/review-10x` or a dedicated correctness pass.

## Output

Emit exactly this block, filled in:

```md
## Architecture Review — <scope>

**Score:** X/10
**Verdict:** PASS | REVISE | BLOCK

### Summary
<2–4 sentences: what was reviewed, overall architectural impression, key concerns.>

### Findings

| # | Severity | File / Area | Finding |
|---|---|---|---|
| 1 | Critical/Major/Minor/Nit | <file or module> | <concise description> |
| … | … | … | … |

### Architecture Fit
<Does the change land in the right layer and module? Any boundary violations?>

### Extensibility
<Does the change preserve extension points? Any rigidity introduced?>

### Simplicity & Duplication
<Unwarranted abstractions? Duplicated logic that should be consolidated?>

### Recommended Actions
- [ ] <action — Critical items first, then Major, then Minor/Nit>

### References
- Architecture context: `.agents/context/architecture.md`
- Conventions: `.agents/context/conventions.md`
```

**Verdict rules:**
- `PASS` — score 8–10, no Critical or Major findings.
- `REVISE` — score 5–7, or one or more Major findings present.
- `BLOCK` — score below 5, or any Critical finding present.

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md)
- **Commands:** `/review-10x`, `/security-review`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
