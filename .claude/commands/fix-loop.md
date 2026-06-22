---
description: Iterate fixes until a target check passes (max 10)
argument-hint: "[failing-check]"
---

# /fix-loop

> Make a specific failing check pass through bounded, root-cause-driven iteration.

## Purpose

Use this when a single check (test, lint, type-check, build step, or CI gate) is failing. Enforces one-hypothesis-at-a-time discipline and a hard cap of **10 iterations**.

Check: **$ARGUMENTS**

## Usage

`/fix-loop <failing-check>` — e.g. `/fix-loop "npm run test -- src/auth.test.ts"` or `/fix-loop "tsc --noEmit"`.

If `$ARGUMENTS` is empty, ask for it before proceeding.

## Preconditions

- On a feature branch or worktree, not the default branch.
- The check is reproducible locally.
- Related checks are identified to detect regressions.

## Procedure

Reproduce the failure, form ONE hypothesis, apply a minimal fix, rerun. Repeat up to 10 iterations. Full schema: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) + [`.agents/workflows/debugging.md`](../../.agents/workflows/debugging.md).

## Stop Conditions

PASS when the check exits 0 and related checks are green; STUCK after 3 consecutive failures with no new hypothesis; CAP at 10. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Never weaken the check to manufacture a pass; never echo or commit secrets. Full rules: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Output

Emits a Fix Loop report. Schema, stop conditions (stuck/cap/blocker), safety rules, and report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md). Root-cause methodology: [`.agents/workflows/debugging.md`](../../.agents/workflows/debugging.md).

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`debugging.md`](../../.agents/workflows/debugging.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/test-loop`, `/ci-debug`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
