# Retrospectives Workflow

After every meaningful completed task, run a retrospective and append it to the log. Retrospectives make the harness self-improving.

**When to use:**
- After a sprint contract is completed and the reviewer has issued a verdict
- After a significant debugging session
- After a worktree session is closed
- After a harness improvement sprint
- After any session with interesting lessons or failures

Skip only for trivial sessions (typo fix, single-line edit, docs correction with no new insights).

---

## Retrospective Principle

Retrospectives should be honest, brief, and actionable. If the session went poorly, say so — that is the most useful input for harness improvement.

Every retrospective appends to `../../.agents/logs/retrospectives.md`. Never overwrite the archive.

---

## Retrospective Format

Append to `../../.agents/logs/retrospectives.md`:

```md
## Retrospective — YYYY-MM-DD — Task Name

### Score
Self-score out of 10. Be honest. If the reviewer gave a different score, note both.

### Reviewer Verdict
PASS / REVISE / BLOCK (or "no reviewer this session").

### What Changed
- Brief list of what was implemented, fixed, or improved

### What Went Well
- What worked, what was efficient, what felt smooth

### What Was Difficult
- What caused friction, required rework, or took longer than expected

### Bugs / Risks Found
- Any bugs discovered during implementation or review
- Any risks that remain after the session

### Harness Gaps Found
- Missing documentation
- Confusing instructions
- Commands that were wrong or missing
- Workflow steps that needed clarification
- Skills or superpowers that should be documented

### Worktree / Env Notes
- Whether the worktree was useful or caused friction
- Any env file issues encountered
- Branch naming or worktree setup issues

### Skills / Superpowers Used
- `/frontend-design` — how it was used and whether it helped
- `/superpowers:*` — which skills were used and their value
- Project-specific skills used

### Improvements for Next Time
- Specific, actionable changes to process, tooling, or harness docs
- Ordered by expected impact

### Follow-up Proposals
- Skill or workflow proposals to create in `../../.agents/proposals/`
- Harness improvements to make
- Issues to open on GitHub
```

---

## After Writing the Retrospective

If the retrospective surfaces harness gaps:

1. Create a proposal in `../../.agents/proposals/` if the gap is significant
2. Update the relevant harness file immediately if the fix is small (e.g., correcting a wrong command in `commands.md`)
3. Open a GitHub issue labeled `type: chore` or `type: docs` if tracking is needed

If the retrospective surfaces repeated patterns:
- Add to `../../.agents/logs/learnings.md`
- Propose a new skill or workflow if the pattern is reusable

---

## Harness Quality Signal

Retrospectives feed directly into the Harness Quality Audit in `./review.md`. If multiple retrospectives flag the same subsystem (e.g., "env file setup was confusing again"), that subsystem's score should drop and an improvement should be proposed.

---

## Related Files

- [`../logs/retrospectives.md`](../logs/retrospectives.md) — where retrospectives are appended
- [`../logs/learnings.md`](../logs/learnings.md) — where reusable lessons are captured
- [`../proposals/`](../proposals/) — where harness improvement proposals are stored
- [`./review.md`](./review.md) — Harness Quality Audit (uses retrospective data)
- [`./handover.md`](./handover.md) — write the handover before or after the retro

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
