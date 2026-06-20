---
description: "Goal-driven loop: define acceptance criteria, then iterate to done (max 6)"
argument-hint: "[goal]"
---

# /goal

> Reach a stated goal whose steps are not fully known up front by first defining measurable acceptance criteria, then iterating to them under a bounded loop.

## Purpose

Use this when you have a clear destination but not a fully spelled-out plan — the goal is known, the path is not. It forces acceptance criteria to be written before any edit is made, then drives a structured iterate-and-verify loop until those criteria are satisfied or the cap is reached.

Goal: **$ARGUMENTS**

## Usage

`/goal <goal description>` — e.g. `/goal make the CI pipeline pass with zero lint and type errors`.

## Parameters

- `$ARGUMENTS` (required) — the goal in one or two sentences. If empty or underspecified, ask for it and any missing constraints before proceeding.

## Preconditions

- Repo state is understood (`git status`); you are on a feature branch or worktree, not the default branch.
- The relevant context has been read: [`AGENTS.md`](../../AGENTS.md), [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Procedure

1. **Restate and specify.** Restate the goal in one sentence. Identify any unknowns that would block a clear definition of done — if the goal is underspecified with no safe default, stop and ask before continuing.

2. **Define acceptance criteria.** Write measurable, binary acceptance criteria in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md) before touching any file. Each criterion must be checkable by a command or observable state (e.g. "all tests pass", "build exits 0", "output contains X"). Record the verification command(s) that will prove each criterion.

3. **Plan the first step.** Identify the single most valuable next action toward the goal. Do not plan all steps up front — just enough to take one verified step. Apply the planning workflow from [`../../.agents/workflows/planning.md`](../../.agents/workflows/planning.md) if the step is non-trivial.

4. **Iterate (max 6 iterations).** For each iteration:
   a. Take the next step (edit, run, fix, or verify).
   b. Run the verification command(s) for the criteria that step should advance.
   c. Record the result (pass/fail + evidence) in [`../../.agents/logs/progress.md`](../../.agents/logs/progress.md).
   d. If a criterion is now met, mark it done. If all criteria are met, go to step 5.
   e. If progress stalled two iterations running (no criterion advanced), go to step 6.
   f. Determine the next best step and repeat.

5. **Declare PASS.** Confirm every acceptance criterion is met with captured evidence. Emit the goal report (see Output). Update logs and any relevant status files.

6. **Escalate.** If all 6 iterations are exhausted without PASS, or if progress stalls two iterations running: stop, record what remains, create follow-up issues for unresolved criteria, and emit the goal report with verdict `STALLED` or `BLOCKED`. Do not loop beyond the cap.

## Stop Conditions

- **Success (PASS):** All acceptance criteria met with verification evidence captured.
- **Cap reached:** 6 iterations completed without PASS — emit the report with outstanding criteria and follow-ups.
- **Stall:** No criterion advanced for two consecutive iterations — escalate immediately rather than spinning.
- **Escalate / stop and ask:** Goal is irreversibly underspecified; an irreversible or outward-facing action with no safe default is required; a hard blocker appears that can't be resolved in-session.
- Never exceed the iteration cap — respect the loop governance in [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

- Write acceptance criteria before any edit. Never start iterating on an undefined goal.
- Confirm before destructive or outward-facing actions (deletes, force-push, migrations, publishing, sending messages).
- Never weaken auth, validation, or rate limits to satisfy a criterion; never commit or echo secrets.
- No AI/LLM attribution in any commit, PR, doc, or comment.
- If verification commands are unavailable, document what was attempted, why it failed, what risk remains, and what to check next — do not claim PASS without evidence.

## Output

Emit a goal report at the end of every run:

```md
## Goal — <goal>
- Acceptance criteria:
  - [ ] <criterion 1> — <PASS|FAIL|OPEN> — <evidence>
  - [ ] <criterion 2> — <PASS|FAIL|OPEN> — <evidence>
- Iterations used: N / 6
- Verdict: PASS | STALLED | BLOCKED
- Follow-ups: <issues or notes, if any>
```

## Related

- **Skills:** `autonomous-loop-design`
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md), [`planning.md`](../../.agents/workflows/planning.md)
- **Commands:** `/build-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
