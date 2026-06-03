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

## 2026-06-03 — Verification: Harden harness template repo (README + CI)

### Commands Run
| Command | Result | Notes |
|---|---|---|
| `bash scripts/verify-harness.sh` | PASS | 11 passed / 0 failed, exit 0 |
| `bash -n scripts/verify-harness.sh` / `bash -n init.sh` | PASS | syntax OK |
| link-checker unit test (titled / angle-bracket / reference forms) | PASS | captures local targets, flags missing |
| `ruby -ryaml` on issue forms + `ci.yml` | PASS | 6/6 valid |
| empty-repo regression run | PASS | exits 1, only legitimate passes remain |

### Artifacts Produced
- CI run on the PR (GitHub Actions "CI" workflow) — see PR #4.
- `verify-harness.sh` console output (11/0) captured this session.

### Failed Attempts
- Round-1 review found false-negative paths in `verify-harness.sh` (M1/M2/m1/m2); all fixed and re-verified adversarially in round 2.

### Remaining Risks
- Verification depends on `python3` (+ `pyyaml`/`ruby`) for JSON/YAML/link checks; CI installs `pyyaml`.

### Links
- Issues: #1 (epic), #2 (README), #3 (CI)
- PR: #4

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
