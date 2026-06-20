---
description: Run tests, fix failures, rerun until green (max 6)
argument-hint: "[test-target]"
---

# /test-loop

> Get a targeted test set passing by diagnosing and fixing root causes, never by weakening or skipping tests.

## Purpose

Use this when a specific test file, suite, or pattern is failing and you want a bounded, disciplined loop that drives it to green. The loop diagnoses real root causes, applies minimal targeted fixes, and re-verifies after each fix. It never relaxes assertions, skips tests, or mocks away real behavior to manufacture a passing run.

Test target: **$ARGUMENTS**

## Usage

`/test-loop [test-target]` — e.g. `/test-loop src/auth/session.test.ts` or `/test-loop --grep "billing"`.

If `$ARGUMENTS` is empty, run the full default test suite for the current worktree.

## Parameters

- `$ARGUMENTS` (optional) — a file path, directory, test-name pattern, or any flag your test runner accepts. Defaults to the project's standard test command if omitted.

## Preconditions

- You are on a feature branch or worktree, not the default branch.
- The project's test runner is installed and `{{TEST_COMMAND}}` is confirmed in [`.agents/context/commands.md`](../../.agents/context/commands.md).
- The working tree is in a consistent state (`git status` clean or staged intentionally).

## Procedure

1. **Baseline run.** Execute `{{TEST_COMMAND}} $ARGUMENTS`. Capture the full output — failed test names, assertion messages, stack traces, and exit code. Do not proceed without reading the output in full.

2. **Triage failures.** For each failing test, identify the root cause: implementation bug, missing dependency, incorrect fixture, environment gap, or genuinely broken test logic. Record the triage in a scratch note. If a test's assertion appears wrong, flag it as a `[SUSPECT]` item and treat it as a blocker — do not silence or skip it; escalate (see Stop Conditions).

3. **Fix root causes.** Apply the minimal change that addresses the real failure. Constraints:
   - Never weaken an assertion (tighten is fine, loosen is a Critical issue).
   - Never add `.skip`, `.only` (unless narrowing scope for diagnosis, then restore before the final run), or `// @ts-ignore` to mask a failure.
   - Never mock out real logic to force a green run.
   - Keep each fix focused and reviewable; avoid refactoring beyond what is needed.

4. **Rerun.** Execute the same `{{TEST_COMMAND}} $ARGUMENTS` command. Compare output to the previous run: confirm previously failing tests now pass and no new failures appeared. If new failures surfaced, treat them as additional triage items for the next iteration.

5. **Iterate.** Repeat steps 2–4 until all targeted tests pass. Increment the iteration counter. Stop at 6 iterations (see Stop Conditions).

6. **Final evidence capture.** On a fully green run, record:
   - The exact command and its full terminal output (pass count, coverage line if available).
   - Which files were changed and why.
   - Any `[SUSPECT]` tests flagged but not modified (note them for follow-up).
   - Update [`.agents/logs/progress.md`](../../.agents/logs/progress.md) with the result.

## Stop Conditions

- **Success:** all targeted tests pass with no skips added, no assertions weakened, evidence captured, logs updated.
- **Escalate — stop and ask:** a `[SUSPECT]` test has incorrect assertions that need a deliberate decision to update; a fix requires changes outside the stated scope (schema, API contract, shared utility); iteration 6 completes without full green.
- **Max iterations reached:** stop at 6. Document: tests still failing, root causes identified but unresolved, files changed so far, recommended next steps. Create a follow-up issue and hand off cleanly — do not loop indefinitely per [autonomous-loops.md](../../.agents/workflows/autonomous-loops.md).

## Safety

- Never weaken, skip, or mock away a real failure. Doing so is a **Critical** issue and must be flagged, not silently committed.
- Never commit test changes that lower coverage thresholds to make CI green.
- No AI/LLM attribution in any commit, PR, doc, or comment.
- Never commit or echo secret values, even if a test fixture references one — use environment variables or anonymised fixtures.
- Confirm before deleting test files or fixtures; that is an irreversible action.

## Output

Emit a test-loop report after each iteration and a final summary on completion:

```md
## Test Loop — <test-target>

**Iteration:** X / 6
**Status:** green | failing | escalated

### Failures this run
- <TestName>: <one-line root cause>

### Fix applied
- <file>: <what changed and why>

### Rerun result
- Passed: N  Failed: N  Skipped: N
- Command: `{{TEST_COMMAND}} $ARGUMENTS`

### Suspect tests (flagged, not modified)
- <TestName>: <reason>

### Follow-ups
- <issue or note>
```

Final report replaces iterations with `**Status: PASS — all targeted tests green**` and links to the evidence output.

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`testing.md`](../../.agents/workflows/testing.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/fix-loop`, `/build-loop`, `/review-10x`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
