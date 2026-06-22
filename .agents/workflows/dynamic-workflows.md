# Dynamic Workflows

Scriptable, repeatable, many-subagent orchestration for audit, migration, and verification tasks.

Use dynamic workflows only when the situation calls for it — consult [orchestration.md](./orchestration.md) for the mode decision matrix and hard limits.

---

## Requires Approval

**Yes.** Before creating a new dynamic workflow, submit a proposal in [../proposals/](../proposals/).

The lead must not execute a new dynamic workflow until the proposal has been reviewed and approved.

---

## Dynamic Workflow Proposal Format

Save proposals to `../proposals/<workflow-name>.md`:

```md
# Proposal: Dynamic Workflow Name

## Problem
What repeated audit, migration, review, or verification task does this solve?

## Trigger
When should this workflow be used?

## Inputs
What files, commands, issues, or feature IDs does it need?

## Worker Strategy
How many subagents (max 8) and what each one checks.

## Output Schema
What structured result should each worker return?

## Implementation Verification
What each implementation worker must verify before returning.

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
- Verification evidence present or justified

## Verification
How results are validated or cross-checked.

## Cost Control
How to avoid unnecessary subagents or repeated work.

## Failure Handling
What happens if workers disagree or produce incomplete findings.

## Requires Approval
Yes.
```

---

## Worker Strategy

Each worker must have:

- **Narrow scope** — a specific module, directory, feature, or question
- **Clear output format** — structured findings, not freeform prose
- **Self-verification** — workers check their own output before returning

Worker output schema (adapt per workflow):

```md
## Worker Report — [Worker ID] — [Scope]

### Scope
Files/modules/features reviewed.

### Findings
| ID | Severity | Description | File | Line | Recommendation |
|---|---|---|---|---|---|

### Verification Performed
Commands or checks run.

### Evidence
Links or inline output.

### Confidence
High / Medium / Low — reason for uncertainty if applicable.
```

---

## Reusable Subagent Roles

Don't hand-write a worker prompt from scratch when a role already fits. The harness ships a roster of **reusable, model-tiered subagents** in [`../../.claude/agents/`](../../.claude/agents/) — assign one to a worker via its `agentType` and it arrives with the right system prompt and tier. Full roster, tiers, and a canonical pipeline are in [`../context/subagents.md`](../context/subagents.md).

| Stage | Role | Tier |
|---|---|---|
| Discover / search | `scout` | haiku |
| Plan / decompose | `planner` | opus |
| Build / cover | `implementer`, `tester` | sonnet |
| Diagnose | `debugger` | sonnet |
| Document | `docs-writer` | sonnet |
| Gate | `reviewer`, `safety-reviewer` | opus |
| Synthesize | `integrator` | opus |
| Evolve | `skill-smith`, `architect` | opus |

Pin each worker to the **cheapest tier that does the job** — let `scout` (haiku) fan out wide for discovery, reserve opus for the review/architecture/synthesis stages. This keeps a many-worker run affordable without sacrificing the gates.

---

Every dynamic workflow must include a reviewer pass after all workers finish — see [review.md](./review.md) for the process and gates, and [autonomous-loops.md](./autonomous-loops.md) for iteration caps, stop conditions, and the Loop Report format.

---

## Cost Control

Before launching workers:

- [ ] Each worker has a narrow, non-overlapping scope
- [ ] Worker count is ≤ 8 (default hard limit)
- [ ] Each worker has a clear output schema
- [ ] Lead will synthesize, not concatenate raw logs
- [ ] Repeat runs reuse prior findings where valid

---

## Failure Handling

| Failure | Action |
|---|---|
| Worker returns empty findings | Mark scope as "no issues found" with confidence level |
| Workers disagree on a finding | Escalate to lead; lead decides or flags for human review |
| Worker cannot access required files | Document missing scope and continue |
| Reviewer blocks after 6 iterations | Stop, document remaining issues, create GitHub Issues |
| Worker produces unstructured output | Reject and re-run with stricter prompt |

---

## Orchestration Log

After the workflow completes, append to [../logs/orchestration.md](../logs/orchestration.md) using the format in [orchestration.md](./orchestration.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
