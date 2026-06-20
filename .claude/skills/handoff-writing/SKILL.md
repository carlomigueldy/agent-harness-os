---
name: handoff-writing
description: Write a compact, complete session handover covering state, next actions, risks, and evidence
---

# Skill: handoff-writing

## Purpose

Produce a compact, self-contained handover so the next session — human or agent — can resume immediately without rediscovering context. A good handover replaces the need to re-read logs, re-run `git status`, or ask "where did we leave off?" It is the minimum durable record of state, intent, and evidence.

## When to Use

- Ending any meaningful coding session (feature work, debugging, review, migration).
- Pausing mid-task when you will not immediately continue.
- Handing an issue or branch to another agent or human reviewer.
- Before running `/final-handoff` or `/issue-handoff` — those commands consume a handover as input.

## When Not to Use

- After a trivial, no-state-change action (reading a file, running a lint check with no findings) — skip if nothing meaningful changed.
- Mid-task when you are about to continue immediately in the same session — no point recording an intermediate state that will be stale in minutes.

## Inputs

- Current `git status` and `git diff --stat` output.
- The sprint contract or issue acceptance criteria the session was working toward.
- Verification evidence captured this session (test output, build logs, screenshots).
- Any blockers or open decisions encountered.

## Outputs

- Updated `session-handoff.md` (root-level, single latest entry — overwrite).
- A new append entry in [`.agents/logs/handover.md`](../../../.agents/logs/handover.md) (cumulative log — never overwrite).

## Procedure

1. **Summarize current state.** In three bullet groups — Done, In Progress, Blocked — record what was completed this session, what is partially done (with the specific stopping point), and what is actively blocked and why. Be concrete: name files changed, commands run, tests passing or failing, PRs opened.

2. **List the next best actions in priority order.** Write 3–5 actions the next session should take, ordered from most to least important. Each action must be unambiguous: include the command to run, the file to touch, or the decision to make. Do not write "continue work" — write "run `{{VERIFY_COMMAND}}` and fix the two failing assertions in `{{FILE}}`."

3. **Note important files, risks, and verification evidence.** Record:
   - Key files touched or left in a partial state (absolute paths or repo-relative).
   - Any open risk, known breakage, or debt introduced — and the severity.
   - Verification evidence: paste or link the final test/lint/build output so the next session knows what was last confirmed working. Reference the format in [`../../../.agents/workflows/handover.md`](../../../.agents/workflows/handover.md).

4. **Write to `session-handoff.md` and append to the handover log.** Overwrite `session-handoff.md` with the latest entry using the standard handover template (see [`../../../.agents/workflows/handover.md`](../../../.agents/workflows/handover.md)). Then append a datestamped entry to `.agents/logs/handover.md`. Never overwrite the log — it is the cumulative history.

5. **Confirm the next best action is unambiguous.** Re-read the "Next Actions" section as if you were the next session seeing it cold. If any step requires mental reconstruction or leaves a decision open, rewrite it until it does not. The handover passes this check when a fresh agent can start the next session from step 1 of the next-actions list with no clarifying questions.

## Checks

- `session-handoff.md` exists at the repo root and reflects the current session (not a stale prior entry).
- `.agents/logs/handover.md` has a new append entry with today's date.
- Every "Next Action" is a concrete, runnable step — no vague phrases like "continue," "look into," or "figure out."
- Any partial or broken state is flagged explicitly under Blocked or Risks — no silent omissions.
- No secrets, credentials, or personally identifiable values are written into the handover files.

## Common Failure Modes

- **Vague next actions.** "Continue implementing X" tells the next session nothing. Always specify file, command, or decision.
- **Omitting blockers.** Leaving a known breakage unmentioned wastes the next session's diagnosis time. State it plainly.
- **Overwriting the log.** `session-handoff.md` is overwritten; `.agents/logs/handover.md` is append-only. Confusing the two corrupts the cumulative record.
- **Stale verification evidence.** Pasting a test result from two hours ago when the code has since changed is worse than no evidence — it creates false confidence. Always capture evidence from the final state.
- **Handover scope creep.** The handover is a compact record, not a design doc. Keep it scannable; deep context belongs in the linked workflow files or issue bodies.

## Example Usage

> Session ends after partially implementing a {{FEATURE_NAME}} endpoint. Verification: unit tests pass but integration test is skipped (missing fixture). Handover records: Done — route scaffolded and unit-tested; In Progress — integration test blocked on missing `{{FIXTURE_FILE}}`; Next Actions — (1) add fixture at `tests/fixtures/{{FIXTURE_FILE}}`, (2) re-run `{{INTEGRATION_TEST_COMMAND}}`, (3) open PR once green. Appended to `.agents/logs/handover.md` and `session-handoff.md` overwritten.

## Related Commands

`/final-handoff`, `/issue-handoff`

## Maintenance Notes

Keep the handover template in step with [`../../../.agents/workflows/handover.md`](../../../.agents/workflows/handover.md). If new required sections are added to the handover format (e.g., a new "Security notes" block), add a matching sub-step to Procedure step 3. If the log path changes, update step 4 and the Checks section. For pre-release handovers, pair with the [release workflow](../../../.agents/workflows/release.md) to ensure the state captured is release-gate-ready.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
