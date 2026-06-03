# Failure Attribution Log

Root-cause record of failures encountered in {{PROJECT_NAME}}. When something fails, do not patch randomly — log it here first.

## Format

```md
## YYYY-MM-DD — Failure Title

### Context
What was being attempted.

### Symptom
What failed.

### Root Cause
Best known cause.

### Category
Instruction / Tool / Environment / State / Feedback / Code / Requirement / External

### Fix
What changed.

### Verification
How the fix was checked.

### Follow-up
What should be improved in the harness to prevent this.
```

**Category definitions:**
| Category | Meaning |
|---|---|
| Instruction | Harness instructions were unclear, missing, or wrong |
| Tool | A CLI, MCP, or harness tool behaved unexpectedly |
| Environment | Missing dependency, wrong version, missing env var |
| State | Stale progress file, wrong branch, dirty worktree |
| Feedback | Reviewer loop, rubric, or acceptance criteria were unclear |
| Code | Bug in application or test code |
| Requirement | The requirement itself was ambiguous or changed |
| External | Third-party service, API, or infrastructure failure |

If the failure was caused by a missing harness feature, propose a harness improvement in [../proposals/](../proposals/).

---

<!-- FILL: Append new failure entries below in reverse-chronological order (newest first). -->

— no entries yet —

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
