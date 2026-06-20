# Autonomous Loops

Bounded, review-gated loops an agent can run without per-step human input. Every loop has a hard iteration cap, explicit stop and escalation conditions, and a handoff — so it makes progress without running forever or shipping unverified work.

Each loop is also an invokable slash command in [`../../.claude/commands/`](../../.claude/commands/) (see [`../context/slash-commands.md`](../context/slash-commands.md)). This file is the doctrine those commands implement.

> **Golden rules (non-negotiable):** always know the active objective and stop condition · never run indefinitely · never hide a failed check · never skip the review gate · never mark work done without updating docs/context/state · always produce a handoff when stopping.

---

## Loop Schema

Every loop is specified with these fields:

| Field | Meaning |
|---|---|
| **Purpose** | What the loop converges toward |
| **Inputs** | What it needs to start |
| **Outputs** | What it produces |
| **Max iterations** | Hard cap — stop even if not converged |
| **Stop conditions** | Success criteria that end the loop early |
| **Escalation** | When to stop and ask a human instead of iterating |
| **Review gate** | The check each iteration must pass |
| **Logging** | Where progress is recorded each iteration |
| **Handoff** | What is written when the loop ends (success or cap) |
| **Failure recovery** | What to do on a failed iteration |

### Iteration caps by loop class

| Class | Cap | Loops |
|---|---|---|
| Implementation | 6 | `/build-loop`, `/goal`, `/issue-loop` |
| Review / fix | 10 | `/review-loop`, `/fix-loop` |
| Test | 6 | `/test-loop` |
| Documentation | 4 | `/docs-loop` |
| Discovery | 3 | `/skill-evolution-loop` |
| Safety | 5 | safety sub-loops inside any review |

**At the cap:** stop. Do not ship if Critical/Major issues remain. If only Minor/Nit remain, document them and create follow-ups. Always record the final verdict and write a handoff.

### Loop Report (emit when any loop ends)

```md
# Autonomous Loop Report
- Loop: /<name>   Objective: <...>
- Max iterations: N   Used: k
- Work completed: <...>
- Files changed: <...>
- Checks run: <commands + results>
- Review status: Score X/10 — Verdict PASS|REVISE|BLOCK
- Remaining work: <...>
- Handoff: <link to session-handoff.md / issue>
```

---

## The Loops

### `/build-loop` — implementation loop
- **Purpose:** implement a scoped task to a 10/10 PASS.
- **Inputs:** task + acceptance criteria (sprint contract).
- **Outputs:** implemented change + verification evidence.
- **Max iterations:** 6.
- **Stop conditions:** acceptance criteria met and review verdict `PASS` (10/10, no Critical/Major).
- **Escalation:** ambiguous requirements, irreversible/outward-facing action with no safe default, repeated same failure.
- **Review gate:** `/review-10x` (skill [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)) each iteration after changes.
- **Logging:** [`../logs/progress.md`](../logs/progress.md) + [`../logs/verification.md`](../logs/verification.md).
- **Handoff:** Loop Report + [`../../session-handoff.md`](../../session-handoff.md).
- **Failure recovery:** on a failed check, do root-cause analysis ([`debugging.md`](debugging.md)), not random patching; log to [`../logs/failures.md`](../logs/failures.md) if the cause is non-obvious.
- **Note:** named `/build-loop`, not `/loop`, to avoid colliding with Claude Code's built-in `/loop`.

### `/goal` — goal-driven loop
- **Purpose:** reach a stated goal whose steps aren't fully known up front.
- **Inputs:** a goal statement.
- **Outputs:** the goal achieved + evidence, or a documented blocker.
- **Max iterations:** 6. **Stop:** goal's acceptance criteria met + `PASS`.
- **Escalation:** goal underspecified, or progress stalls two iterations running.
- **Review gate / logging / handoff / recovery:** as `/build-loop`. First iteration **defines** measurable acceptance criteria before any edit.

### `/autonomous-loop` — meta loop selector
- **Purpose:** pick and launch the right loop for the situation.
- **Inputs:** a task/target. **Outputs:** delegates to one loop below and returns its report.
- **Max iterations:** N/A (selects once). **Stop:** the chosen loop ends.
- **Procedure:** classify the work (implement / fix / test / docs / review / discover) → run the matching loop with its cap.

### `/review-loop` — review-until-pass
- **Purpose:** drive a change to a 10/10 `PASS` through repeated review + fix.
- **Inputs:** a change + acceptance criteria. **Outputs:** PASS verdict or documented residual issues.
- **Max iterations:** 10.
- **Stop:** reviewer returns 10/10 `PASS`. **Escalation:** Critical issue that can't be fixed in-session.
- **Review gate:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) each round; fix Critical/Major between rounds.
- **Logging:** [`../logs/verification.md`](../logs/verification.md). **Handoff:** final Review Result block.

### `/fix-loop` — fix-until-green
- **Purpose:** make a specific failing check pass.
- **Inputs:** the failing command/check. **Outputs:** the check passing, or a documented root-cause blocker.
- **Max iterations:** 10.
- **Stop:** the target check exits 0. **Escalation:** same failure 3× with no new hypothesis → stop and log to [`../logs/failures.md`](../logs/failures.md).
- **Review gate:** the target check itself + no regressions in related checks.
- **Failure recovery:** one hypothesis per iteration; follow [`debugging.md`](debugging.md).

### `/test-loop` — tests-until-green
- **Purpose:** get a targeted test set passing.
- **Inputs:** the test target/command. **Outputs:** green tests + evidence.
- **Max iterations:** 6. **Stop:** all targeted tests pass. **Escalation:** a failure that reveals a spec/requirements gap.
- **Review gate:** the test run; never weaken or skip a test to pass — that is a Critical issue.

### `/docs-loop` — docs-until-accurate
- **Purpose:** bring docs in line with reality.
- **Inputs:** the docs scope. **Outputs:** accurate docs, resolving links, within length limits.
- **Max iterations:** 4. **Stop:** content accurate, `verify-harness.sh` link + length checks pass.
- **Review gate:** markdown link resolution + entry-file length limits (`verify-harness.sh`).

### `/issue-loop` — work a set of issues
- **Purpose:** clear a queue of issues, one at a time.
- **Inputs:** issue numbers/list. **Outputs:** each issue resolved via its own `/build-loop`.
- **Max iterations:** 6 issues per session unless approved. **Stop:** queue empty or cap reached.
- **Escalation:** an issue needs a decision or is out of scope → skip + note. **Logging:** update each issue + [`../logs/progress.md`](../logs/progress.md).

### `/skill-evolution-loop` — discover reusable skills
- **Purpose:** find repeated workflows worth turning into skills/commands.
- **Inputs:** recent session history / logs. **Outputs:** skill/command proposals or new skills.
- **Max iterations:** 3 (stop after 2 dry rounds with no new pattern).
- **Stop:** no new reusable pattern found. **Review gate:** each proposed skill conforms to the [skill schema](../context/skills.md) and adds real value (not duplication).
- **Handoff:** proposals in [`../proposals/`](../proposals/) or new skills under `.claude/skills/`.

---

## Relationship to the review loop

These loops reuse the harness's existing review machinery — the 1–10 scoring, the PASS/REVISE/BLOCK verdict, and the strict-mode 10/10 rule — defined in [`review.md`](review.md) and [`../../evaluator-rubric.md`](../../evaluator-rubric.md). A loop is just that review loop wrapped in an iteration cap and a typed objective.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
