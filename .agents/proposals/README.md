# Proposals

Proposals are structured requests to change or extend the harness in a meaningful, permanent way.

> **Rule:** All proposals require human approval before being adopted into the harness.

---

## When to Add a Proposal

Add a proposal when you want to:

- Create a **new skill or superpower** for a repeated task pattern
- Create a **new dynamic workflow** for a repeatable multi-subagent orchestration
- Make a **significant change to an existing workflow**, context file, or harness structure
- Add a new **log format**, **orchestration rule**, or **feedback loop variant**
- Retire or consolidate existing harness files

Do NOT add a proposal for:

- Routine log updates (use `../logs/` directly)
- Small typo or clarity fixes to existing docs (edit directly)
- One-off task execution (use `../workflows/` instead)

If in doubt, create a proposal rather than silently mutating core workflows.

---

## Naming Convention

```
NNNN-short-title.md
```

- `NNNN` — zero-padded sequential number (e.g. `0001`, `0042`)
- `short-title` — lowercase kebab-case, 3–6 words
- Examples:
  - `0001-add-screenshot-capture-skill.md`
  - `0002-security-audit-dynamic-workflow.md`
  - `0003-split-review-into-two-phases.md`

Number proposals in the order they are created. Do not reuse numbers.

---

## Proposal Formats

Use the matching format for your proposal type.

---

### Skill or Workflow Proposal

Use when proposing a new skill, a new project-specific workflow step, or an improvement to an existing skill or workflow.

```md
# Proposal: Skill or Workflow Name

## Problem
What repeated task, failure mode, or friction point does this solve?
Be specific — link to a log entry, retrospective, or observed pattern.

## Proposed Skill / Workflow
What should be created or changed? One sentence description.

## Trigger
When should agents invoke this skill or follow this workflow?
What signals indicate it should be used?

## Inputs
What information, files, commands, or feature IDs does it need?

## Steps
1. Step one
2. Step two
3. ...

## Expected Benefit
How it improves speed, quality, cost, or reliability.
Be concrete — estimate time saved or risk reduced.

## Risks
What could go wrong if this skill or workflow is adopted incorrectly?

## Requires Approval
Yes.
```

---

### Dynamic Workflow Proposal

Use when proposing a new repeatable multi-subagent orchestration pattern.

```md
# Proposal: Dynamic Workflow Name

## Problem
What repeated audit, migration, review, or verification task does this solve?

## Trigger
When should this workflow be used?

## Inputs
What files, commands, issues, or feature IDs does it need?

## Worker Strategy
How many subagents should be used and what each one checks.
Stay within the default limit of 8 workers unless justified.

## Output Schema
What structured result should each worker return?

## Implementation Verification
What each implementation worker must verify before returning results.

## Reviewer Feedback Loop
How reviewer scoring works.

Reviewer must output:
- Score: X/10
- Verdict: PASS / REVISE / BLOCK
- Critical issues
- Major issues
- Minor issues
- Nit issues
- Evidence checked
- Required follow-up

Passing requires:
- Score: 10/10
- Verdict: PASS
- No Critical issues
- No Major issues
- Verification evidence present or clearly justified

## Verification
How results are validated or cross-checked across workers.

## Cost Control
How to avoid unnecessary subagents or repeated work.

## Failure Handling
What happens if workers disagree or produce incomplete findings.

## Requires Approval
Yes.
```

---

### Harness Improvement Proposal

Use when proposing a structural change to the harness itself — adding files, splitting workflows, changing log formats, retiring redundant files, or revising core rules.

```md
# Proposal: Title

## Problem
What is inefficient, risky, unclear, repetitive, or low-quality in the current harness?
Reference the subsystem affected: Instructions / Tools / Environment / State / Feedback.

## Proposed Change
What should change, and in which files?

## Expected Benefit
How this improves speed, quality, cost, or reliability.

## Risks
What could go wrong if adopted? What depends on the current behavior?

## Migration Plan
How to adopt the change safely without breaking existing sessions.

## Requires Approval
Yes.
```

---

## Proposal Status

Track proposal status in the proposal file itself. Add a status line at the top after the title:

```md
**Status:** Draft | Under Review | Approved | Rejected | Adopted
**Opened:** YYYY-MM-DD
**Decision:** YYYY-MM-DD — brief reason (if decided)
```

Adopted proposals should be noted in [`../logs/decisions.md`](../logs/decisions.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
