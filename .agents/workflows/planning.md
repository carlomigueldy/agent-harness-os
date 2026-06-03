# Planning Workflow

The Planner role translates product intent into a verified, scoped sprint contract that implementation agents can execute safely.

**When to use:** Before any non-trivial implementation. Skip only for trivial edits (formatting, typo fixes, minor docs).

---

## Planner Responsibilities

The Planner must never dive into low-level implementation details too early. The goal is a clear, scoped, risk-aware contract — not a wall of code.

---

## Planning Steps

### 1. Understand product intent
Before decomposing work, answer:
- What user problem does this solve?
- What does success look like from the user's perspective?
- What is the simplest version that would satisfy the acceptance criteria?
- Are the requirements clear enough to start? If not, stop and ask.

### 2. Review current state
- Read `../../claude-progress.md` and `../../.agents/logs/progress.md`
- Check `../../feature_list.json` for the feature's current status
- Check relevant GitHub issues if available
- Identify what was completed, what is blocked, and what decisions were already made in `../../.agents/logs/decisions.md`

### 3. Decompose the work
Break the feature or task into the smallest verifiable units:
- Each unit should be independently testable
- Each unit should have a clear owner (especially in multi-agent mode)
- Mark which units are parallel-safe and which are sequential
- Identify shared files that create sequential constraints

### 4. Identify risks
Flag before implementation begins:
- Shared architecture changes (require sequential)
- Migration or data contract changes (require sequential)
- Security, auth, payments, secrets, or production config (require sequential + evaluator)
- UI/UX changes that need visual verification
- External dependencies or third-party APIs
- Known flaky tests or unstable environments
- Missing env files or missing tool access

### 5. Define acceptance criteria
Write specific, verifiable criteria. Bad: "it works". Good:
```
- User can submit the form and receive a success message
- API returns 200 with correct shape when given valid input
- Error state displays inline validation for required fields
- Unit tests pass for the new utility function
- E2E test covers the happy path
```

### 6. Define the verification plan
Map each acceptance criterion to a command or artifact:
```
- {{LINT_CMD}} — no new errors
- {{TYPECHECK_CMD}} — clean
- {{TEST_CMD}} — all related tests pass
- {{BUILD_CMD}} — build succeeds
- Screenshot of feature — captured in .agents/artifacts/
```

See `../../.agents/context/commands.md` for actual project commands.

### 7. Define the demo plan
For user-facing changes:
- Which screen or flow should be captured?
- Screenshot, GIF, or CLI output?
- Before/after comparison needed?
- Store artifacts in `.agents/artifacts/`

### 8. Select orchestration mode
Use the decision matrix in [`./orchestration.md`](./orchestration.md) to choose:

| Situation | Mode |
|---|---|
| Small scoped edit | Single agent |
| Focused investigation | Subagent |
| Repo-wide audit | Dynamic workflow |
| Complex cross-module feature | Agent team |
| High-risk change | Sequential single agent + evaluator |

Document the choice and reasoning in the sprint contract.

### 9. Select relevant skills and superpowers
Check `../../.agents/context/skills.md`. Identify:

- Does this involve frontend, UI, UX, responsive layout, or accessibility? → Consider `/frontend-design`
- Does this require architecture, debugging, code review, or testing? → Check relevant `/superpowers:*` skills
- Are there project-specific skills listed that apply?

Document in the sprint contract under **Skills / Superpowers**.

### 10. Write the sprint contract
Use the format below and append it to `../../.agents/logs/progress.md`.

```md
## Sprint Contract — Task Name

### Goal
What needs to be achieved.

### Scope
What will be changed.

### Non-goals
What will not be changed.

### Acceptance Criteria
- ...

### Verification Plan
- ...

### Demo Plan
- ...

### Dependencies
- ...

### Blockers
- ...

### Worktree
Branch/path/env status.

### Skills / Superpowers
Relevant `/frontend-design` or `/superpowers:*` usage.

### Orchestration Mode
Single agent / subagent / agent team / dynamic workflow / sequential manual.

### Parallelization Assessment
Sequential required / parallel-safe.

### Risk Level
Low / medium / high.

### Model Tier
Haiku / Sonnet / Opus-level.

### Done Means
Clear definition of done.
```

### 11. Hand off to implementation
Before handing off, confirm:
- [ ] Sprint contract is written in `../../.agents/logs/progress.md`
- [ ] Worktree is created or selected
- [ ] Env files are copied and not staged
- [ ] Verification commands are known
- [ ] Skills/superpowers are identified
- [ ] Orchestration mode is selected
- [ ] Risk level is documented
- [ ] GitHub issue is linked (if available)

---

## What Planners Must Not Do

- Do not start implementation before the sprint contract exists
- Do not define acceptance criteria so vague they cannot be verified
- Do not assume the stack — reference `../../.agents/context/architecture.md` and `../../.agents/context/conventions.md`
- Do not force parallel work when requirements are unclear
- Do not select an agent team or dynamic workflow for a task a single agent can handle

---

## Related Files

- [`../../AGENTS.md`](../../AGENTS.md) — hard constraints and definition of done
- [`../context/skills.md`](../context/skills.md) — available skills and superpowers
- [`./orchestration.md`](./orchestration.md) — execution mode decision matrix
- [`./initialization.md`](./initialization.md) — sprint contract format (canonical copy)
- [`../logs/progress.md`](../logs/progress.md) — where sprint contracts are stored
- [`../logs/decisions.md`](../logs/decisions.md) — prior decisions to consult

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
