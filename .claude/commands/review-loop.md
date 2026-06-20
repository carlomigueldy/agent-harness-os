---
description: "Review-until-pass: score 1-10 until 10/10 PASS (max 10)"
argument-hint: "[target]"
model: opus
---

# /review-loop

> Drive a change to a 10/10 PASS through repeated independent review and fixing of Critical/Major issues.

## Purpose

Use this when a change needs to reach verified, reviewer-quality completion. The loop runs an independent review against the [evaluator rubric](../../evaluator-rubric.md), scores it 1–10, fixes every Critical and Major finding, and re-reviews until the score reaches 10/10 PASS or the iteration cap is hit. It is the canonical autonomous gate for ensuring nothing ships unverified.

Target: **$ARGUMENTS**

## Usage

`/review-loop [target]` — e.g. `/review-loop feat/auth-module` or `/review-loop` (defaults to the current working diff).

If `$ARGUMENTS` is empty, derive the target from `git diff --name-only HEAD` and state it explicitly before proceeding.

## Parameters

- `$ARGUMENTS` (optional) — the branch name, file glob, PR number, or diff reference to review. Defaults to the staged/unstaged diff in the current worktree if omitted.

## Preconditions

- You are on a feature branch or worktree, **not** the default branch.
- The change compiles, lints, and passes any available automated checks before the first review iteration.
- The [evaluator rubric](../../evaluator-rubric.md) has been read and is loaded in context.
- `git status` is clean or the relevant files are staged.

## Procedure

1. **Identify and state the target.** Resolve `$ARGUMENTS` to a concrete diff, file set, or branch. State what will be reviewed and why. Read the relevant files; do not review from memory.

2. **Run iteration 1: independent review.** Adopt the role of an independent senior reviewer with no stake in the implementation. Review the target against the full [evaluator rubric](../../evaluator-rubric.md). Score each criterion; derive an overall score 1–10. Emit the Review Result block (see Output).

3. **Classify findings.** For each finding assign severity: `Critical` (correctness, security, data-loss risk), `Major` (logic bug, missing test, significant design flaw), `Minor` (style, naming, non-blocking improvement), `Nit` (trivial preference). A score of 10/10 PASS requires zero Critical and zero Major findings.

4. **Fix Critical and Major findings.** Apply fixes in the current worktree. For each fix, state the finding addressed, the change made, and confirm the fix does not introduce a new issue. Do not fix Minor or Nit items unless the fix is trivial and risk-free — note them for the follow-up list instead.

5. **Re-run verification.** After fixing, re-run lint, typecheck, and tests (match scope to the change type per the verification table in [`../../CLAUDE.md`](../../CLAUDE.md)). Confirm all checks pass before the next review iteration.

6. **Repeat (up to 10 iterations).** Return to step 2 for a fresh review of the updated diff. Each iteration must produce a new Review Result block. Do not skip to a conclusion — each round must re-examine the full target, not just the patched lines.

7. **Reach 10/10 PASS or exhaust the cap.** On reaching 10/10 PASS with zero Critical/Major findings, stop and emit the final Loop Summary. If the cap of 10 iterations is reached without PASS: stop, document all residual findings, create a follow-up issue or note per finding, and emit the Loop Summary with verdict `CAP_REACHED`.

## Stop Conditions

- **Success:** Score `10/10`, verdict `PASS`, zero Critical and zero Major findings, verification passes.
- **Cap reached:** 10 iterations completed without PASS. Document residuals; emit `CAP_REACHED`. Do not continue looping.
- **Block:** A Critical finding cannot be fixed without a design decision or irreversible action (e.g., a schema migration, outward-facing API break). Stop and ask — surface the blocker clearly before taking any action.
- Never bypass the cap by relabeling Critical issues as Minor to force a PASS.

See the iteration-limit and escape-hatch rules in [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

- Never commit or echo secrets. If a review finding involves a secret or credential, redact it in the Review Result block and flag it as Critical.
- No AI/LLM attribution in any commit, PR, doc, or code comment produced during fixing.
- Do not weaken auth, validation, rate limits, or permission checks to resolve a finding — that is a `BLOCK`, not a fix.
- Confirm before any outward-facing or irreversible action surfaced by review (force-push, migration, publish, delete).
- Fixes must not silently change behavior outside the reviewed scope — state the blast radius of each fix before applying.

## Output

Emit one **Review Result** block per iteration:

```md
## Review Result — Iteration <N>
- Target: <what was reviewed>
- Score: <X>/10
- Verdict: PASS | REVISE | BLOCK
- Findings:
  - [Critical] <finding>
  - [Major] <finding>
  - [Minor] <finding>
  - [Nit] <finding>
- Fixes applied this iteration: <list or "none">
- Verification: <commands run + outcomes>
```

After the final iteration, emit a **Loop Summary**:

```md
## Review Loop Summary
- Target: <what was reviewed>
- Iterations: <N> / 10
- Final Score: <X>/10
- Final Verdict: PASS | CAP_REACHED | BLOCK
- Residual findings (unfixed): <list or "none">
- Follow-up issues created: <list or "none">
- Verification evidence: <final check results>
```

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/review-10x`, `/build-loop`, `/gated-orchestration`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
