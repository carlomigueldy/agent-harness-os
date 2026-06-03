# Debugging Workflow

Systematic, evidence-based approach to diagnosing and fixing failures. Do not patch randomly.

**When to use:** Any time a verification step fails, a build breaks, a test regresses, or unexpected behavior appears.

---

## Core Principle

Every failure gets diagnosed before it gets patched.

Random patches waste time, create new failures, and hide root causes. Follow this workflow even for failures that seem obvious — the obvious cause is often wrong.

---

## When `/superpowers:systematic-debugging` Is Available

If the `/superpowers:systematic-debugging` skill is listed in `../../.agents/context/skills.md`, invoke it first:

```
/superpowers:systematic-debugging
```

It provides a structured, repo-aware debugging session. Use the failure attribution format below to record the outcome regardless.

---

## Debugging Steps

### 1. Reproduce the failure
Before changing anything:
- Run the failing command exactly as documented
- Capture the full output (exit code, stdout, stderr)
- Note the environment: branch, worktree, OS, runtime version, dependency versions

If the failure is not reproducible, document that and stop. A non-reproducible failure is a risk to record, not a bug to fix.

### 2. Isolate the scope
Narrow down:
- Does the failure happen in isolation, or only with specific inputs?
- Does it happen on the default branch too, or only this branch?
- Does it happen in a clean install?
- Which change introduced it? (`git bisect` if needed)

### 3. Form a hypothesis
State a single best hypothesis before touching any code:
- What is the most likely root cause?
- What evidence supports or contradicts it?
- What would confirm it?

Avoid forming multiple hypotheses and patching them all simultaneously.

### 4. Verify the hypothesis
Run a targeted check to confirm or disprove:
- Add a log, assertion, or test that reveals the state at the point of failure
- Check the actual vs expected value
- Confirm the fix makes the failure go away before changing anything else

### 5. Apply a minimal fix
Fix only what the hypothesis identifies. Do not refactor surrounding code in the same commit.

### 6. Verify the fix
Run the same command that failed. Confirm it passes. Then run the broader test suite to check for regressions:

```
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}}
{{BUILD_CMD}}
```

See `../../.agents/context/commands.md` for actual commands.

### 7. Record failure attribution
Append to `../../.agents/logs/failures.md` using the format below. Even small failures deserve a record if they took time to diagnose.

---

## Failure Attribution Format

Record in `../../.agents/logs/failures.md`:

```md
## YYYY-MM-DD — Failure Title

### Context
What was being attempted when the failure occurred.

### Symptom
What was observed (error message, unexpected output, failing test name).

### Root Cause
Best known cause based on evidence.

### Category
Instruction / Tool / Environment / State / Feedback / Code / Requirement / External

### Fix
What changed to resolve it.

### Verification
How the fix was confirmed (command run, output observed).

### Follow-up
What should be improved in the harness, environment, or codebase to prevent this.
```

### Category definitions

| Category | Meaning |
|---|---|
| **Instruction** | Missing or misleading harness docs caused the agent to do the wrong thing |
| **Tool** | A command, script, or MCP tool did not work as expected |
| **Environment** | Missing env variable, wrong runtime version, missing dependency |
| **State** | Stale progress file, wrong branch, inconsistent feature state |
| **Feedback** | Verification was skipped or evidence was accepted without checking |
| **Code** | Logic error, type error, integration bug |
| **Requirement** | The acceptance criteria or design were unclear or wrong |
| **External** | Third-party service, API, or network issue |

---

## If Harness Caused the Failure

If the root cause is a harness gap (Category: Instruction, Tool, Environment, State, or Feedback), create a proposal in `../../.agents/proposals/`:

```md
# Proposal: Harness Improvement for [Failure Title]

## Problem
What harness gap caused this failure.

## Proposed Change
What should be added or fixed in the harness.

## Expected Benefit
How it prevents similar failures.

## Risks
Any downside.

## Migration Plan
How to adopt safely.

## Requires Approval
Yes.
```

---

## Anti-Patterns

- Patching without diagnosing
- Forming and patching multiple hypotheses simultaneously
- Marking a fix as done before running verification
- Ignoring a failure because it "seemed intermittent"
- Not recording failures that took time to debug — the next session will hit the same issue

---

## Related Files

- [`../context/commands.md`](../context/commands.md) — all project commands for re-running checks
- [`../logs/failures.md`](../logs/failures.md) — where all failure attributions are recorded
- [`../logs/learnings.md`](../logs/learnings.md) — where debugging insights are captured
- [`./testing.md`](./testing.md) — verification workflow by change type

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
