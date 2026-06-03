# Verification Evidence Log

Captures commands run, results, errors, failed attempts, artifacts produced, and links to issues/PRs for {{PROJECT_NAME}}.

Never claim a test passed unless it actually passed. If verification cannot run, explain what was attempted, why it failed, what risk remains, and what should be checked next.

## Entry Template

```md
## YYYY-MM-DD — Verification: Task or Feature Name

### Commands Run
| Command | Result | Notes |
|---|---|---|
| `command here` | PASS / FAIL / SKIP | Any relevant output |

### Artifacts Produced
- `path/to/screenshot.png` — description
- `path/to/test-output.txt` — description

### Failed Attempts
- Attempted: `command` — Reason it failed: ...

### Remaining Risks
- ...

### Links
- Issue: #N/A
- PR: #N/A

### Verified By
Implementation agent / reviewer / manual check.
```

---

## Example Entry

```md
## YYYY-MM-DD — Verification: Auth Login Flow

### Commands Run
| Command | Result | Notes |
|---|---|---|
| `{{LINT_CMD}}` | PASS | No lint errors |
| `{{TYPECHECK_CMD}}` | PASS | No type errors |
| `{{TEST_CMD}} --grep auth` | PASS | 12 tests passed |

### Artifacts Produced
- `.agents/artifacts/login-flow-YYYY-MM-DD.png` — screenshot of login UI

### Failed Attempts
- Attempted: `{{E2E_CMD}}` — Reason it failed: dev server not running in CI

### Remaining Risks
- E2E coverage of OAuth path not yet verified

### Links
- Issue: #12
- PR: #15

### Verified By
Implementation agent.
```

---

<!-- FILL: Append new verification entries below in reverse-chronological order (newest first). -->

— no entries yet —

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
