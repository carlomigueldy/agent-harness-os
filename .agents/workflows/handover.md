# Handover Workflow

Write a compact, information-dense handover at the end of every significant session so the next session can continue without rediscovery.

**When to use:** Before ending any session that made meaningful progress, got blocked, or changed the project state in any way.

---

## Handover Principle

Keep handovers compact. Do not dump the whole session.

The goal is to answer: "What does the next session need to know that it cannot easily rediscover from the repo itself?"

---

## Two Handover Destinations

Every handover writes to **both**:

1. **`../../session-handoff.md`** — overwrite with the latest handover (always reflects the most recent session)
2. **`../../.agents/logs/handover.md`** — append to the archive (never overwrite, grows over time)

---

## Handover Format

```md
## Handover — YYYY-MM-DD HH:mm

### Current State
One or two sentences: what is the overall status of the project right now?

### Completed
- What was finished this session (link to PR/issue if available)

### In Progress
- What was started but not finished

### Next Best Action
1. Most important first step for the next session
2. Second step
3. Third step (optional)

### Important Files
- `path/to/file` — why it matters to the next session

### Worktree / Branch
- Branch: `branch-name`
- Worktree path: `../{{REPO_NAME}}-worktrees/branch-name` (or N/A)
- Env file status: Copied / Missing / Not needed

### Commands Run
- `{{LINT_CMD}}` — passed / failed with details
- `{{TEST_CMD}}` — passed / failed with details

### Verification
- What was verified and the result
- What could not be verified and why

### Demo / Evidence
- Artifact path or "none" with reason

### Reviewer Score / Verdict
- Score: X/10 (or "not reviewed this session")
- Verdict: PASS / REVISE / BLOCK / not reviewed

### Open Issues / PRs
- #123 — brief description

### Blockers / Risks
- What is blocking progress or poses risk

### Context to Preserve
Important context the next session would waste time rediscovering (e.g., why a certain approach was chosen, a tricky environment behavior, a dependency constraint).

### Recommended Next Mode
Planning / Implementation / Review / Debugging / Testing / Documentation
```

---

## Pre-Handover Checklist

Complete before writing the handover. See [`../../clean-state-checklist.md`](../../clean-state-checklist.md) for the full checklist.

---

## What to Omit

Do not include in the handover:
- Full command transcripts (keep only results, not raw output)
- Code snippets (the repo has the code)
- Repeated context already visible in `AGENTS.md` or `claude-progress.md`
- Speculation about things that were not attempted

---

## When to Write a Handover

Always write a handover when:
- Ending any meaningful coding session
- A session is interrupted unexpectedly
- Switching from one task to a different one
- Handing off to a different agent, model tier, or worktree

Skip the handover only for trivial sessions (read-only, no changes, no new context).

---

## Related Files

- [`../../session-handoff.md`](../../session-handoff.md) — latest handover (always current)
- [`../logs/handover.md`](../logs/handover.md) — archived handover history
- [`../../claude-progress.md`](../../claude-progress.md) — current progress state
- [`../../feature_list.json`](../../feature_list.json) — machine-readable feature tracker
- [`./retrospectives.md`](./retrospectives.md) — write a retro after completing significant work

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
