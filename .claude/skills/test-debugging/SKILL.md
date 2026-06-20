---
name: test-debugging
description: Systematically diagnose and fix a failing test using isolate, hypothesize, verify — without weakening the test
---

# Skill: test-debugging

## Purpose

Find and fix the root cause of a failing test. The target outcome is a green test that exercises the same contract it originally did — not a patched assertion, a skipped block, or a broadened matcher that hides the real defect. Follow the isolate → hypothesize → verify loop documented in [`../../../.agents/workflows/debugging.md`](../../../.agents/workflows/debugging.md).

## When to Use

- A test is failing locally or in CI and the root cause is not immediately obvious.
- CI is red on a test suite and you need to triage which tests are broken and why.
- `/test-loop`, `/fix-loop`, or `/ci-debug` drive you here as a sub-procedure.
- A previously passing test has regressed after a code change.

## When Not to Use

- The test itself is genuinely wrong (incorrect assertion, stale contract, wrong expectation): fix the test deliberately, document *why* the expectation changed, and treat that as an intentional test update — not a bug fix.
- The failure is an environment issue (missing dependency, wrong env var, uninitialized DB): fix the environment first; debugging the test is premature until the environment is stable.
- The failure is a known, pre-existing flake that has a tracked issue: check whether the flake is in scope for this session before spending cycles on it.

## Inputs

- The failing test name(s), file path(s), and the exact error output or stack trace.
- The commit or diff under investigation (if the failure is a regression).
- Access to run the test suite or a subset of it (`{{TEST_COMMAND}}`).
- The source under test — the implementation file(s) the test exercises.

## Outputs

- A passing test (or a passing suite) with the same assertions as before — the test contract is preserved.
- A root-cause note appended to [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md) when the cause is non-obvious, recording: symptom → hypothesis → fix → confirmation.
- No weakened, skipped, or commented-out test left behind.

## Procedure

1. **Reproduce the failure deterministically.** Run the failing test in isolation and capture the exact error message, stack trace, and any relevant log output. If the failure is intermittent, run it at least three times. Do not proceed until you have a reliable reproduction — a flake that only fails in CI needs its environment reproduced locally or the CI logs captured in full.

2. **Isolate the smallest failing case.** Narrow to the single test (or the single assertion within it) that is failing. Remove noise: disable unrelated tests in the file temporarily if the runner supports `--grep` / `--filter` / focus syntax. Confirm that running only the isolated case still fails. This step prevents diagnosing the wrong thing.

3. **Form one hypothesis at a time.** Read the error message and the stack trace carefully. Identify the exact line where the failure occurs. Form a single, falsifiable hypothesis about the cause — a changed return value, a missing mock, a wrong fixture state, an async ordering issue, a data type mismatch. Write it down before acting on it. Do not chase multiple theories simultaneously.

   - If the hypothesis involves the implementation: read the relevant source and diff to see whether recent changes match the symptom.
   - If the hypothesis involves test setup: inspect `beforeEach`, fixtures, mocks, and teardown.
   - Add a targeted log statement or assertion to confirm or refute the hypothesis, then run the test again.
   - Keep or discard the hypothesis based on evidence. If discarded, form the next one.

4. **Fix the root cause; never weaken or skip the test.** Apply the minimal change to the implementation (or to test setup/fixtures when the fixture itself was wrong) that makes the test pass. Do not modify the assertion to match broken behavior. Do not add `.skip`, `xit`, `xtest`, `TODO`, or `@Ignore` to silence the failure. If you believe the test expectation is genuinely wrong, that is a deliberate test update — stop, document the rationale, and treat it as a separate commit.

5. **Rerun the full targeted set; confirm no regressions; log if non-obvious.** After the fix, run the full test file (or the affected module's suite) to verify no regressions were introduced. Then run the broader suite if feasible. If the root cause was non-obvious (e.g., a subtle concurrency issue, a hidden shared-state dependency, or a framework version incompatibility), append a root-cause note to [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md) so the next session has context.

## Checks

- The originally failing test now passes without its assertions changed.
- No other tests were newly broken by the fix.
- No `.skip`, `xit`, `xtest`, `@Ignore`, or equivalent was added.
- The fix targets the implementation or the test setup — not the assertion threshold.
- If the fix touched production code, confirm the change is intentional and covered (pair with [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) for non-trivial changes).
- The root-cause note exists in `verification.md` if the cause was non-obvious.

## Common Failure Modes

- **Weakening the assertion** — changing `toEqual(42)` to `toBeDefined()` or broadening a matcher to make the test go green. This hides the real defect and leaves the contract untested. Never do this without a documented, intentional rationale.
- **Skipping instead of fixing** — adding `.skip` to silence a red test in CI. This is never the correct resolution in a debugging loop.
- **Diagnosing the wrong test** — when multiple tests fail, fixing a downstream failure caused by an upstream one. Always reproduce in isolation first.
- **Trusting the description over the error** — reading the test name and guessing the cause instead of reading the actual stack trace. Read the error first.
- **Stopping at "it passes now" without running regressions** — a fix that makes one test pass by breaking two others is not a fix.
- **Environment drift mistaken for a code bug** — if the failure only occurs in CI, check env vars, secrets, database state, and dependency versions before touching the code.

## Example Usage

> `/ci-debug` flags a regression: `PaymentService > calculates total with discount` fails with `Expected 90, received 100`. The implementer runs the test in isolation — confirmed red. Reads the stack trace: the discount was applied before tax instead of after a recent refactor. Forms hypothesis: field evaluation order changed. Inspects the diff — confirmed. Fixes the order in the implementation. Reruns the isolated test — green. Runs the full `PaymentService` suite — all pass. Appends a one-line root-cause note to `verification.md`. Done.

## Related Commands

`/test-loop`, `/fix-loop`, `/ci-debug`

## Maintenance Notes

- Update `{{TEST_COMMAND}}` in the Inputs section to match the actual test runner once the stack is known (e.g., `npm test`, `pytest`, `go test ./...`, `bundle exec rspec`).
- If the project adds a dedicated test-log or flake-tracking file, add a pointer to it in the Outputs section.
- Keep the debugging loop in step 3 in sync with [`../../../.agents/workflows/debugging.md`](../../../.agents/workflows/debugging.md) if that workflow's isolate/hypothesize/verify pattern changes.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
