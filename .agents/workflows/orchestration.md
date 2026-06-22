# Orchestration

Select the right execution mode before starting any non-trivial task.

## When to Use

Consult this document at the start of every non-trivial task, before writing any code or spawning any subagent.

---

## Orchestration Decision Matrix

| Situation | Preferred Mode | Reason |
|---|---|---|
| Small scoped edit | Single agent | Lowest overhead |
| Unclear requirements | Single agent planning first | Avoid wasted parallel work |
| Focused investigation | Subagent | Keeps main context clean |
| Independent review | Subagent | Isolated second opinion |
| Many repeated checks | Dynamic workflow | Scriptable and reusable |
| Repo-wide audit | Dynamic workflow | Many independent workers |
| Large mechanical migration | Dynamic workflow or batch/worktrees | Repeatable, parallelizable |
| Complex feature across modules | Agent team | Role-based collaboration |
| Competing debugging hypotheses | Agent team or subagents | Parallel exploration |
| Agents need to talk to each other | Agent team | Direct teammate communication |
| Shared files or migrations | Sequential single agent | Avoid conflicts |
| High-risk security/payment/auth change | Sequential + evaluator | Reduce risk |
| Frontend visual/design work | Single agent + `/frontend-design`, or reviewer loop | Design quality needs visual check |
| Low token budget | Single agent or one subagent | Cost control |

### Rule of Thumb

```
Single agent first.
Subagent for isolated focus.
Dynamic workflow for repeatable many-worker audits or migrations.
Agent team for collaborative complex work.
Sequential execution for high-risk or overlapping changes.
Use /frontend-design for relevant frontend/design quality work.
Use /superpowers:* skills when relevant.
```

---

## Hard Limits

These limits apply by default. Exceed them only with explicit approval and a written proposal.

| Limit | Default |
|---|---|
| Max subagents | 3 |
| Max agent team size (including lead) | 4 |
| Max dynamic workflow workers | 8 |
| Max feedback iterations | 6 |
| Max active implementation branches | 1 unless parallel-safe |
| Max active worktrees per task | 1 unless agent team or dynamic workflow requires more |

To request an exception, create a proposal in [../proposals/](../proposals/).

---

## Required Orchestration Log

Whenever subagents, agent teams, or dynamic workflows are used, append an entry to all three of:

- [../logs/orchestration.md](../logs/orchestration.md)
- [../logs/progress.md](../logs/progress.md)
- [../logs/verification.md](../logs/verification.md)

Use this format exactly:

```md
## Orchestration Log — YYYY-MM-DD — Task Name

### Mode Used
Single agent / subagents / agent team / dynamic workflow.

### Why This Mode
Reason this mode was selected.

### Workers / Roles
- ...

### Scope Partition
- ...

### Worktrees
- Branch/path/env status.

### Skills / Superpowers Used
- `/frontend-design` if used.
- `/superpowers:*` skills if used.

### Commands / Tools Used
- ...

### Implementation Verification
What builders verified before handoff.

### Reviewer Score
X/10.

### Reviewer Verdict
PASS / REVISE / BLOCK.

### Critical Issues
- ...

### Major Issues
- ...

### Minor Issues
- ...

### Nit Issues
- ...

### Findings
- ...

### Decisions Made
- ...

### Final Verification
- ...

### Cost Notes
What was done to avoid unnecessary usage.

### Follow-up
- ...
```

---

## Cost Control Before Spawning Workers

Before using subagents, agent teams, or dynamic workflows, confirm:

- [ ] Task is large enough to justify the overhead
- [ ] Work can be partitioned cleanly
- [ ] Each worker has a narrow scope
- [ ] Each worker has clear output requirements
- [ ] Shared files are avoided or explicitly assigned
- [ ] Verification is planned before implementation begins
- [ ] Lead agent will synthesize results compactly
- [ ] Final handover will not include unnecessary raw logs

---

## Related Workflows

- [agent-teams.md](./agent-teams.md) — when to use agent teams, role definitions, assessment template
- [dynamic-workflows.md](./dynamic-workflows.md) — when to use dynamic workflows, proposal format, worker strategy
- [worktrees.md](../context/worktrees.md) — worktree setup and env file handling per worker

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
