# Implementation Workflow

The Builder role executes a scoped sprint contract, keeps changes targeted, runs verification continuously, and produces evidence before handoff.

**When to use:** After a sprint contract exists and the worktree is set up. Never start implementation without a contract.

> For iterative, loop-based implementation with review gates, use the `/build-loop` command — see [`./autonomous-loops.md`](./autonomous-loops.md) for the loop schema, iteration caps, and stop conditions.

---

## Builder Responsibilities

- Implement exactly what the sprint contract defines — no scope creep
- Keep changes scoped to assigned files and modules
- Update docs near changed code (inline comments, local AGENTS.md, commands.md)
- Run targeted verification continuously — not just at the end
- Capture demo evidence for user-facing changes
- Record verification evidence in `../../.agents/logs/verification.md`
- Report clearly if any verification cannot run

Never hand off unverified work when verification is reasonably possible.

---

## Verification

Run the right checks for the change type. See [`./testing.md`](./testing.md) for the full verification workflow by change type, the recording-evidence template, and anti-patterns.

See [`../context/commands.md`](../context/commands.md) for actual project commands.

---

## Pre-Handoff Checklist

Before handing off to review:
- [ ] All acceptance criteria addressed
- [ ] Lint passes
- [ ] Typecheck passes
- [ ] Targeted tests pass
- [ ] Build succeeds (if practical)
- [ ] Demo evidence captured (if user-facing)
- [ ] `../../.agents/logs/verification.md` updated
- [ ] `../../feature_list.json` updated
- [ ] No secrets staged (`git diff --cached`)
- [ ] No env files staged
- [ ] No AI/LLM attribution in any commit message, comment, or doc
- [ ] Sprint contract acceptance criteria reviewed against implementation

---

## When Verification Cannot Run

Document in `../../.agents/logs/verification.md` — never silently skip. See [testing.md § When Verification Cannot Run](./testing.md) for the template.

---

## What Builders Must Not Do

- Do not implement outside the sprint contract scope without updating the contract first
- Do not hand off unverified work when verification was reasonably possible
- Do not stage env files
- Do not add LLM attribution to commits, comments, or docs
- Do not patch randomly when something fails — see [`./debugging.md`](./debugging.md) for the systematic approach
- Do not leave `feature_list.json` showing `"status": "passing"` without evidence

---

## Related Files

- [`./autonomous-loops.md`](./autonomous-loops.md) — `/build-loop` schema, iteration caps, stop conditions
- [`../context/commands.md`](../context/commands.md) — all project commands
- [`./testing.md`](./testing.md) — full verification workflow by change type
- [`./demo-capture.md`](./demo-capture.md) — how to capture and store demo evidence
- [`../logs/verification.md`](../logs/verification.md) — where evidence is recorded
- [`../../feature_list.json`](../../feature_list.json) — machine-readable feature tracker
- [`../logs/progress.md`](../logs/progress.md) — sprint contracts

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
