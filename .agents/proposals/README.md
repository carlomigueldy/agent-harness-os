# Proposals

Proposals are structured requests to change or extend the harness in a meaningful, permanent way.

> **Rule:** All proposals require human approval before being adopted into the harness.

## When to Add a Proposal

Add a proposal for: new skills/superpowers, new dynamic workflows, significant workflow/context/structure changes, new log formats, or retiring harness files.

Do NOT add a proposal for routine log updates, small typo fixes, or one-off task execution.

If in doubt, create a proposal rather than silently mutating core workflows.

## Naming Convention

```
NNNN-short-title.md
```

`NNNN` — zero-padded sequential number (e.g. `0001`). `short-title` — lowercase kebab-case, 3–6 words. Do not reuse numbers.

## Proposal Format

Every proposal file should include:

- **Problem** — what friction, risk, or gap does this solve? Link to a log entry or observed pattern.
- **Proposed Change** — what should be created or changed, and in which files?
- **Expected Benefit** — how it improves speed, quality, cost, or reliability.
- **Risks** — what could go wrong if adopted incorrectly?
- **Requires Approval: Yes**

Dynamic workflow proposals additionally include: Worker Strategy, Output Schema, Reviewer Feedback Loop, Cost Control, and Failure Handling sections.

## Proposal Status

Add a status block at the top of each proposal file:

```md
**Status:** Draft | Under Review | Approved | Rejected | Adopted
**Opened:** YYYY-MM-DD
**Decision:** YYYY-MM-DD — brief reason (if decided)
```

Adopted proposals should be noted in [`../logs/decisions.md`](../logs/decisions.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
