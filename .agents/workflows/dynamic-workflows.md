# Dynamic Workflows

Scriptable, repeatable, many-subagent orchestration for audit, migration, and verification tasks.

## When to Use

Use dynamic workflows when:

- The task needs many subagents working in parallel
- The workflow will be run more than once
- The process is systematic and repeatable
- The output can be validated against a rubric
- Workers only need to return structured findings (not discuss tradeoffs)
- The task is too broad for one agent but too structured for agent-team discussion

Good use cases:

- Repo-wide codebase audit
- Security review
- Performance audit
- Accessibility audit
- Large mechanical migration (e.g., dependency upgrade, API rename)
- Test coverage audit
- Documentation freshness audit
- Cross-module architecture review
- Find every place a pattern exists and classify risk
- Review all features against `feature_list.json` and verify evidence

**Dynamic workflows vs. agent teams:**

| Use dynamic workflow when... | Use agent team when... |
|---|---|
| Workflow can be scripted | Agents need to discuss tradeoffs |
| Workers return structured findings | Agents need to negotiate ownership |
| Same workflow should be rerun later | Work is exploratory or creative |
| Task is audit-like or migration-like | Real-time plan adaptation is needed |
| Collaboration between workers is NOT needed | Agents need to talk to each other |

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

## Reviewer Feedback Loop

Every dynamic workflow must include a reviewer pass after all workers finish.

**Pass requires all of:**

```
Score: 10/10
Verdict: PASS
Critical issues: 0
Major issues: 0
Verification evidence: present or justified
No secrets referenced without masking
No LLM attribution
```

**Loop:**

1. Workers complete structured findings.
2. Lead synthesizes findings compactly.
3. Reviewer evaluates against acceptance criteria and rubric.
4. Reviewer scores 1–10 and gives verdict: `PASS` / `REVISE` / `BLOCK`.
5. Critical and Major issues trigger another worker pass (scoped to affected areas).
6. Loop repeats up to max 6 iterations.

If iteration 6 is reached and Critical or Major issues remain, do not declare pass. Document and create follow-up issues.

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
