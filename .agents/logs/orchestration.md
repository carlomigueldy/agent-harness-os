# Orchestration Log

Records every use of subagents, agent teams, or dynamic workflows in {{PROJECT_NAME}}. Append an entry whenever multi-agent orchestration is used.

Also update [./progress.md](./progress.md) and [./verification.md](./verification.md) after each orchestrated session.

## Format

```md
## Orchestration Log — YYYY-MM-DD — Task Name

### Mode Used
Single agent / subagents / agent team / dynamic workflow.

### Why This Mode
Reason this mode was selected over simpler alternatives.

### Workers / Roles
- Lead: ...
- Builder: ...
- Tester: ...
- Reviewer: ...
- (add/remove roles as needed)

### Scope Partition
- Worker A owned: ...
- Worker B owned: ...

### Worktrees
- Branch/path/env status per worker.

### Skills / Superpowers Used
- List any skills invoked.

### Commands / Tools Used
- `command` — purpose

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

**Hard limits** (require explicit approval to exceed):
| Limit | Default |
|---|---|
| Max subagents | 3 |
| Max agent team size (including lead) | 4 |
| Max dynamic workflow workers | 8 |
| Max feedback iterations | 6 |
| Max active implementation branches | 1 (unless parallel-safe) |
| Max active worktrees per task | 1 (unless agent team or dynamic workflow) |

---

<!-- FILL: Append new orchestration entries below in reverse-chronological order (newest first). -->

— no entries yet —

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
