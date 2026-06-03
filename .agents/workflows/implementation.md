# Implementation Workflow

The Builder role executes a scoped sprint contract, keeps changes targeted, runs verification continuously, and produces evidence before handoff.

**When to use:** After a sprint contract exists and the worktree is set up. Never start implementation without a contract.

---

## Builder Responsibilities

- Implement exactly what the sprint contract defines — no scope creep
- Keep changes scoped to assigned files and modules
- Update docs near changed code (inline comments, local AGENTS.md, commands.md)
- Run targeted verification continuously — not just at the end
- Capture demo evidence for user-facing changes
- Record verification evidence in `../../.agents/logs/verification.md`
- Report clearly if any verification cannot run

Implementation agents must not hand off unverified work when verification is reasonably possible.

---

## Implementation Steps

### 1. Confirm the sprint contract
Read the active sprint contract in `../../.agents/logs/progress.md`. Confirm:
- Scope is clear
- Acceptance criteria are specific and verifiable
- Worktree is created and env files are copied
- Verification commands are known (see `../../.agents/context/commands.md`)
- Skills/superpowers for this task are identified

### 2. Confirm worktree state
```
git worktree list
git status
git branch --show-current
```
Ensure you are on the correct branch in the correct worktree. Never implement directly on the default branch for non-trivial changes.

### 3. Implement in small, verifiable increments
- Make one logical change at a time
- Commit frequently with clear messages (no AI attribution)
- Avoid refactoring unrelated code in the same commit
- If an unexpected dependency or issue appears, stop and update the sprint contract before continuing

### 4. Update docs near changed code
For every meaningful change:
- Update inline comments if the logic is non-obvious
- Update local `AGENTS.md` if the responsibility of a module changed
- Update `../../.agents/context/commands.md` if commands changed
- Update `../../.agents/context/architecture.md` if architectural assumptions changed

### 5. Run targeted verification by change type

**Frontend change:**
```
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}} [targeted test file or suite]
{{BUILD_CMD}}
# Capture screenshot/demo if user-facing
```

**Backend change:**
```
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}} [targeted test file or suite]
# API smoke test if practical
```

**Contract / blockchain change:**
```
# Compile contracts
# Unit tests
# Invariant/fuzz tests if relevant
# Deployment dry-run if relevant
```

**Docs-only change:**
```
# Markdown lint if available
# Link/path sanity check
# Fresh readability check
```

See `../../.agents/context/commands.md` for the actual project commands and `./testing.md` for the full verification workflow.

### 6. Record verification evidence
After each verification run, append to `../../.agents/logs/verification.md`:

```md
## YYYY-MM-DD — Verification: Task Name

### Commands Run
- `command` — result/output summary

### Pass / Fail
Pass / Fail with details.

### Artifacts
- Screenshot/GIF/log path if applicable

### Remaining Risks
Any verification that could not run and why.
```

### 7. Capture demo evidence (user-facing changes)
For any change a user can see:
- Take a screenshot or record a GIF
- Store in `.agents/artifacts/`
- Reference the artifact in `../../.agents/logs/verification.md`
- Update `../../feature_list.json` with `"evidence"` pointing to the artifact

For frontend/design work, use `/frontend-design` if available.

### 8. Update feature state
In `../../feature_list.json`, update the feature:
- Set `"status": "in_progress"` during implementation
- Set `"status": "passing"` only after verification evidence exists
- Add evidence references

### 9. Pre-handoff checklist
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

If verification cannot run, the implementation agent must document in `../../.agents/logs/verification.md`:

```md
## YYYY-MM-DD — Verification Blocked: Task Name

### What Was Attempted
Which commands were run or attempted.

### Why It Could Not Run
Environment issue, missing dependency, timeout, etc.

### What Remains Risky
Which acceptance criteria are unverified.

### Next Step
Which command or artifact the reviewer or next session should check.
```

Never claim verification passed when it did not. Never claim evidence exists when it does not.

---

## What Builders Must Not Do

- Do not implement outside the sprint contract scope without updating the contract first
- Do not hand off unverified work when verification was reasonably possible
- Do not stage env files
- Do not add LLM attribution to commits, comments, or docs
- Do not patch randomly when something fails — see `./debugging.md` for the systematic approach
- Do not leave `feature_list.json` showing `"status": "passing"` without evidence

---

## Related Files

- [`../context/commands.md`](../context/commands.md) — all project commands
- [`./testing.md`](./testing.md) — full verification workflow by change type
- [`./demo-capture.md`](./demo-capture.md) — how to capture and store demo evidence
- [`../logs/verification.md`](../logs/verification.md) — where evidence is recorded
- [`../../feature_list.json`](../../feature_list.json) — machine-readable feature tracker
- [`../logs/progress.md`](../logs/progress.md) — sprint contracts

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
