# Review Workflow

The Evaluator/Reviewer role scores implementation output against the sprint contract, issues a binding verdict, and runs the Harness Quality Audit.

**When to use:**
- After any non-trivial implementation before marking a feature `passing`
- After any autonomous feedback loop iteration
- Periodically to audit harness health (use the Harness Quality Audit section)

---

## Reviewer Responsibilities

- Review output against the sprint contract acceptance criteria
- Check all verification evidence provided by implementation agents
- Score quality from 1–10
- Issue a verdict: `PASS`, `REVISE`, or `BLOCK`
- Classify every issue found by severity
- Check for LLM attribution, secrets, and worktree hygiene
- Decide whether another iteration is needed

For scoring dimensions, verdict rules, severity definitions, and the Review Result block template, see [evaluator-rubric.md](../../evaluator-rubric.md).

---

## Review Checklist

Work through these in order. A `BLOCK` verdict can be issued at any point.

**Verification Evidence**
- [ ] Implementation agent ran lint, typecheck, and targeted tests
- [ ] Build was run if practical
- [ ] If user-facing: screenshot/GIF/demo exists in `.agents/artifacts/`
- [ ] `../../.agents/logs/verification.md` is updated
- [ ] If verification could not run: reason is documented and honest

**Sprint Contract**
- [ ] All acceptance criteria are addressed
- [ ] Scope matches — no unexpected changes outside the contract
- [ ] Non-goals were not accidentally implemented

**Code Quality**
- [ ] Logic is correct and matches the intended behavior
- [ ] No obviously brittle or over-engineered patterns introduced
- [ ] Docs near changed code are updated where relevant

**Security and Safety**
- [ ] No secrets staged (`git diff --cached`)
- [ ] No env files staged
- [ ] No real credentials in any file, comment, or log

**Harness Hygiene**
- [ ] No LLM/AI attribution in commits, comments, docs, or changelogs
- [ ] `../../feature_list.json` updated with correct status and evidence
- [ ] `../../.agents/logs/progress.md` reflects current state
- [ ] `../../.agents/logs/changelog.md` has an entry if meaningful work completed
- [ ] Worktree is on the correct branch
- [ ] Env files are not staged

**Handover Quality**
- [ ] `../../session-handoff.md` is up to date
- [ ] `../../.agents/logs/handover.md` has an entry appended
- [ ] Next best action is clear

---

## The Six Review Gates

Substantial changes pass through up to six gates, in order. Each is an independent lens; a `BLOCK` at any gate stops the change. Lightweight changes may collapse several gates into one pass — scale the gate set to the risk.

| # | Gate | Checks | Driven by |
|---|---|---|---|
| 1 | **Implementation** | Correctness vs acceptance criteria; verification evidence; no regressions | `/review-10x` → [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md) |
| 2 | **Architecture** | Fits harness conventions; extensible; no needless complexity or duplication | `/architecture-review` |
| 3 | **Test** | New behavior is covered; edge cases; tests not weakened to pass | `/test-loop` → [`test-debugging`](../../.claude/skills/test-debugging/SKILL.md) |
| 4 | **Documentation** | Docs/context updated; links resolve; entry-file length limits respected | `/docs-loop` → [`documentation-maintenance`](../../.claude/skills/documentation-maintenance/SKILL.md) |
| 5 | **Safety** | No secrets/attribution; destructive ops gated; loops bounded; authz intact | `/security-review` → [`security-review`](../../.claude/skills/security-review/SKILL.md) |
| 6 | **Final integration** | Units merged cleanly; full verification green; state/handoff updated | `/review-10x` + `/final-handoff` |

Each gate emits a Review Result block (template: [evaluator-rubric.md → Review Result Block](../../evaluator-rubric.md#review-result-block)). Record gate results in [`../logs/verification.md`](../logs/verification.md). A change is "done" only when every applicable gate is `PASS`.

For feedback loop mechanics, iteration caps, and stop conditions, see [autonomous-loops.md](autonomous-loops.md).

---

## Harness Quality Audit

Run this audit periodically to identify harness debt. Treat harness debt like technical debt.

Score each subsystem from 1 (critical gaps) to 5 (excellent, self-improving).

This audit expands the **five core subsystems** (Instructions, Tools, Environment, State, Feedback — see [`../README.md`](../README.md)) into **eight scoring dimensions** by breaking out three cross-cutting concerns (Worktrees, Orchestration, Skills/Superpowers) that span multiple subsystems and deserve their own score.

<!-- FILL: After running a session, score each subsystem based on observed evidence -->

| Subsystem | Score (1–5) | Evidence | Weakness | Improvement |
|---|---:|---|---|---|
| **Instructions** | | AGENTS.md, CLAUDE.md clarity and coverage | | |
| **Tools** | | commands.md completeness, skill documentation | | |
| **Environment** | | environment.md, init.sh, env file guidance | | |
| **State** | | progress.md, feature_list.json freshness | | |
| **Feedback** | | review loop usage, verification evidence quality | | |
| **Worktrees** | | worktrees.md adoption, env file hygiene | | |
| **Orchestration** | | orchestration.md usage, mode selection quality | | |
| **Skills / Superpowers** | | skills.md coverage, actual usage in sessions | | |

> TEMPLATE NOTE: Fill in scores after each meaningful session. A total below 30/40 indicates harness debt requiring a harness sprint.

**Scoring key:**
- **5** — Excellent, actively used, self-improving
- **4** — Good, minor gaps
- **3** — Functional but incomplete
- **2** — Significant gaps impeding agents
- **1** — Missing or critically broken

---

## Related Files

- [`../../evaluator-rubric.md`](../../evaluator-rubric.md) — scoring dimensions, verdict rules, severity definitions, Review Result block template
- [`autonomous-loops.md`](autonomous-loops.md) — bounded loops that wrap this review machinery
- [`../context/slash-commands.md`](../context/slash-commands.md) — the review/gate commands (`/review-10x`, `/architecture-review`, `/security-review`)
- [`../logs/verification.md`](../logs/verification.md) — where verification evidence is stored
- [`../logs/progress.md`](../logs/progress.md) — sprint contracts and progress state
- [`../logs/handover.md`](../logs/handover.md) — archived handovers

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
