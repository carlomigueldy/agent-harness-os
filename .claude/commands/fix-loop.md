---
description: Iterate fixes until a target check passes (max 10)
argument-hint: "[failing-check]"
---

# /fix-loop

> Make a specific failing check pass through bounded, root-cause-driven iteration.

## Purpose

Use this when a single check (test, lint rule, type-check, build step, or CI gate) is failing and you need a disciplined, hypothesis-driven loop to make it pass without introducing regressions. It enforces one-hypothesis-at-a-time discipline and a hard cap of 10 iterations so the loop never spirals.

Check: **$ARGUMENTS**

## Usage

`/fix-loop <failing-check>` — e.g. `/fix-loop "npm run test -- src/auth.test.ts"` or `/fix-loop "tsc --noEmit"`.

## Parameters

- `$ARGUMENTS` (required) — the shell command or check name to fix. If empty, ask for it before proceeding.

## Preconditions

- You are on a feature branch or worktree, not the default branch.
- The check is reproducible locally — you can run it and observe the failure.
- Related checks (sibling test files, full lint, build) are identified so regressions can be detected.

## Procedure

1. **Reproduce.** Run `$ARGUMENTS` exactly as given. Capture the full error output — exit code, message, file, line, stack trace. Record the initial failure in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md) with a timestamp and iteration counter starting at 1.
2. **Hypothesize.** Form ONE specific, falsifiable hypothesis about the root cause. Write it down before touching any code. Never apply a speculative shotgun fix.
3. **Fix.** Apply the minimal change that tests the hypothesis. Avoid touching unrelated code. Do not commit yet.
4. **Rerun.** Execute `$ARGUMENTS` again. Also run any related checks (sibling tests, lint, typecheck) to confirm no regressions were introduced.
5. **Evaluate.** Three outcomes:
   - Check passes and related checks are green → go to Stop Conditions (success).
   - Check fails with a *new* error → form a new hypothesis and return to step 2.
   - Check fails with the *same* error → increment the recurrence counter. If the same failure has now recurred 3 consecutive times with no new hypothesis available, stop immediately (see Stop Conditions: stuck).
6. **Iterate.** Repeat steps 2–5, incrementing the iteration count each time. Stop at 10 regardless of outcome.

## Stop Conditions

- **Success:** `$ARGUMENTS` exits 0 and all related checks remain green. Capture final verification evidence — commands run and exit codes — in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md).
- **Stuck (same failure × 3):** Stop. Undo uncommitted changes that did not help. Write a structured failure entry to [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md) recording: the check command, the exact error, every hypothesis tried, and a recommended next step (escalate, add debug logging, open a bug report).
- **Cap reached (10 iterations):** Same action as stuck — stop, undo dead-end changes, document findings, and surface as a blocker. Do not loop past 10.
- **Blocker discovered mid-loop:** If resolving the failure requires an irreversible or outward-facing action (schema migration, published API change, secret rotation, dependency removal), stop and ask before proceeding.

Never loop indefinitely — respect the iteration caps in [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

- Never commit failing or partially-fixed code.
- Do not weaken the check (lower thresholds, add skip/exclusion flags, comment out assertions) to manufacture a pass — fix the root cause.
- Never echo or commit secrets; if the error exposes a secret value, redact it in all logs and reports.
- No AI/LLM attribution in any commit, PR, or comment.
- Confirm before any destructive action (file deletion, schema change, dependency removal).

## Output

Emit a fix-loop report:

```md
## Fix Loop — <check>
- Iterations: <n> / 10
- Initial error: <one-line summary>
- Hypotheses tried: <numbered list>
- Outcome: PASS | STUCK | CAP_REACHED
- Verification: <commands + exit codes>
- Regressions: none | <list>
- Follow-ups: <issues/notes if stuck or capped>
```

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`debugging.md`](../../.agents/workflows/debugging.md), [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/test-loop`, `/ci-debug`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
