# Testing Workflow

Verification-first testing workflow. Run the right checks for the right change type — before handoff, not after.

**When to use:** During implementation (see `./implementation.md`) and when the reviewer asks for a verification pass.

---

## Core Principle

Implementation agents must run relevant verification as much as possible before handoff.

If verification cannot run, document why in `../../.agents/logs/verification.md` — do not silently skip it.

---

## Commands Reference

All actual commands for this project are in:
```
../../.agents/context/commands.md
```

The placeholders below map to those commands:

| Placeholder | Command |
|---|---|
| `{{INSTALL_CMD}}` | Install dependencies |
| `{{LINT_CMD}}` | Lint |
| `{{TYPECHECK_CMD}}` | Type check |
| `{{TEST_CMD}}` | Unit / integration tests |
| `{{E2E_CMD}}` | End-to-end tests |
| `{{BUILD_CMD}}` | Build |
| `{{FORMAT_CMD}}` | Format |

<!-- FILL: Replace placeholders with actual commands after project discovery -->

---

## Verification by Change Type

### Frontend Change

```
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}} [targeted component or suite]
{{BUILD_CMD}}
# Screenshot or GIF if user-facing — store in .agents/artifacts/
# Check responsive states where practical
# Check accessibility basics where practical (contrast, keyboard nav, alt text)
```

For design/UI changes: use `/frontend-design` if available to get a structured visual review.

Evidence required:
- Test output (pass/fail count)
- Screenshot or GIF in `.agents/artifacts/`
- Build success confirmation

---

### Backend Change

```
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}} [targeted service, handler, or module]
# API smoke test if practical (curl, httpie, or test client)
```

Evidence required:
- Test output (pass/fail count, coverage if available)
- API response for the changed endpoint (if applicable)

---

### Contract / Blockchain Change

```
# Compile contracts
# Unit tests
# Invariant or fuzz tests if relevant
# Deployment dry-run if relevant and safe
```

Evidence required:
- Compile output (success/error count)
- Test output
- Dry-run output if deployment-related

Sequential execution required — contract changes must not be parallelized without explicit approval.

---

### Docs-Only Change

```
# Markdown lint if available
# Link and path sanity check (verify cross-links resolve)
# Fresh-session readability check: can a new agent answer the fresh session questions?
```

Evidence required:
- Lint output or confirmation lint not available
- List of links checked and their resolution status

---

### Infrastructure / Config Change

```
{{LINT_CMD}}
# Dry-run or plan output if applicable (e.g. terraform plan)
# Validate config schema if a validator exists
```

Sequential execution required.

---

### Full Verification Pass (pre-PR or pre-release)

Run all of the following in order:

```
{{INSTALL_CMD}}
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}}
{{BUILD_CMD}}
{{E2E_CMD}}
```

Capture output. Store in `../../.agents/logs/verification.md`.

---

## Recording Evidence

After every verification run, append to `../../.agents/logs/verification.md`:

```md
## YYYY-MM-DD — Verification: Task Name

### Commands Run
- `command` — result summary

### Pass / Fail
Pass / Fail with details.

### Artifacts
- Path to screenshot/GIF/log if applicable

### Remaining Risks
Any verification that could not run and why.
```

---

## When Verification Cannot Run

Document clearly — never omit:

```md
## YYYY-MM-DD — Verification Blocked: Task Name

### What Was Attempted
Which commands were attempted.

### Why It Could Not Run
Missing env variable, service unavailable, tool not installed, etc.

### What Remains Risky
Which acceptance criteria are unverified.

### Next Step
What the reviewer or next session should check first.
```

---

## Anti-Patterns

- Running all tests when only targeted tests are needed (slow, noisy)
- Skipping verification because "the code looks right"
- Claiming tests passed without running them
- Recording evidence that was not actually produced
- Treating agent agreement as proof of correctness
- Skipping final build verification before a PR

---

## Related Files

- [`../context/commands.md`](../context/commands.md) — all project commands
- [`../logs/verification.md`](../logs/verification.md) — where evidence is recorded
- [`./implementation.md`](./implementation.md) — builder workflow (delegates verification steps here)
- [`./review.md`](./review.md) — reviewer checks evidence during scoring

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
