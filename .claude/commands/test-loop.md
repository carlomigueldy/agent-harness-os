---
description: Run tests, fix failures, rerun until green (max 6)
argument-hint: "[test-target]"
---

# /test-loop

> Get a targeted test set passing by diagnosing and fixing root causes, never by weakening or skipping tests.

## Purpose

Use this when a specific test file, suite, or pattern is failing. Diagnoses real root causes, applies minimal targeted fixes, and re-verifies after each fix. Max **6 iterations**. Never relaxes assertions, skips tests, or mocks away real behavior.

Test target: **$ARGUMENTS**

## Usage

`/test-loop [test-target]` — e.g. `/test-loop src/auth/session.test.ts` or `/test-loop --grep "billing"`.

Omit to run the full default test suite.

## Preconditions

- On a feature branch or worktree, not the default branch.
- The project's test runner is installed; `{{TEST_COMMAND}}` confirmed in [`.agents/context/commands.md`](../../.agents/context/commands.md).
- Working tree in a consistent state.

## Procedure

Run the test target, triage failures, fix root causes minimally, rerun. Repeat up to 6 iterations. Full schema: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) + [`.agents/workflows/testing.md`](../../.agents/workflows/testing.md).

## Stop Conditions

PASS when all targeted tests are green with no skips and no weakened assertions; escalate on `[SUSPECT]` tests or at iteration 6. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Never weaken assertions, add `.skip`, or mock real behavior to force a pass. Never commit secrets in fixtures. Full rules: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Output

Emits a Test Loop report per iteration and a final summary. Schema, stop conditions (escalate on suspect tests), safety rules, and report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Testing methodology: [`.agents/workflows/testing.md`](../../.agents/workflows/testing.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`testing.md`](../../.agents/workflows/testing.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/fix-loop`, `/build-loop`, `/review-10x`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
