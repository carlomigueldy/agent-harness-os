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

---

## Scoring Guide

| Score | Meaning |
|---|---|
| 10/10 | All criteria met, evidence present, no issues |
| 8–9/10 | Minor/Nit issues only, no Critical or Major |
| 6–7/10 | Major issues present, must be fixed |
| 1–5/10 | Critical issues, blocking problems, or missing evidence |

---

## Verdict Rules

```
PASS   — Score 10/10, zero Critical issues, zero Major issues, verification evidence present or justified
REVISE — Score 7–9/10, Minor/Nit issues only, or Major issues that are fixable without a full rewrite
BLOCK  — Score 1–6/10, any Critical issue, missing evidence, staged secrets, or LLM attribution found
```

In autonomous feedback loops, `PASS` requires exactly 10/10. There is no partial pass.

---

## Issue Severity Definitions

| Severity | Definition | Action Required |
|---|---|---|
| **Critical** | Broken functionality, security flaw, staged secret, missing evidence claimed as present, LLM attribution | Must fix before any pass |
| **Major** | Acceptance criterion not met, test suite not run, architectural violation, scope creep | Must fix before pass |
| **Minor** | Suboptimal approach, missing doc update, test gap that does not block the feature | Should fix, document if deferred |
| **Nit** | Style, naming, formatting, minor wording | Fix if trivial, otherwise document |

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

## Reviewer Output Format

```md
## Review — YYYY-MM-DD — Task Name

### Score
X/10

### Verdict
PASS / REVISE / BLOCK

### Critical Issues
- ...

### Major Issues
- ...

### Minor Issues
- ...

### Nit Issues
- ...

### Evidence Checked
- Verification log: present / absent
- Demo artifact: present / absent / not required
- Test output: present / absent

### Compliance
- No LLM attribution: confirmed / VIOLATION FOUND
- No secrets staged: confirmed / VIOLATION FOUND
- Feature state updated: yes / no

### Required Actions Before Next Pass
1. ...

### Approved to Merge / Continue
Yes / No
```

---

## Autonomous Feedback Loop Rules

1. Planner defines acceptance criteria
2. Builder implements and verifies
3. Reviewer evaluates and scores
4. Reviewer issues verdict
5. Critical and Major issues must be fixed
6. Loop repeats until `Score: 10/10` and `Verdict: PASS`
7. Maximum iterations: **6**

After iteration 6:
- Do not pass if Critical or Major issues remain
- If only Minor/Nit issues remain, document them and create follow-up issues
- Record final verdict regardless

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
| **Worktrees** | | worktree-sessions.md adoption, env file hygiene | | |
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

- [`../../evaluator-rubric.md`](../../evaluator-rubric.md) — detailed scoring rubric for all quality dimensions
- [`../logs/verification.md`](../logs/verification.md) — where verification evidence is stored
- [`../logs/progress.md`](../logs/progress.md) — sprint contracts and progress state
- [`../logs/handover.md`](../logs/handover.md) — archived handovers

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
