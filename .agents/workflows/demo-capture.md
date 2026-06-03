# Demo-Driven Completion

Capture real evidence that a feature works before declaring it done.

## When to Use

- After completing any user-facing feature or visible change
- Before closing a GitHub Issue or merging a PR
- When a reviewer asks for verification evidence
- After any change that touches UI, API responses, or observable behavior

---

## Evidence Types

Choose the most appropriate form of evidence. Prefer higher-fidelity options.

| Type | Best For | Tools |
|---|---|---|
| Screenshot | UI states, layouts, responsive views | `/frontend-design`, Playwright, Chrome DevTools |
| GIF / screen recording | Interactions, animations, flows | OS capture tools |
| Short video | Complex multi-step flows | OS capture tools |
| CLI output | Commands, scripts, build output | Terminal capture |
| Test report | Automated assertions | `{{TEST_CMD}}` output |
| Browser automation output | E2E flows | Playwright traces, `{{E2E_CMD}}` |
| Before / after comparison | Regressions, visual fixes | Side-by-side screenshots |
| API response | Backend changes | `curl`, Postman, test output |

---

## Frontend and Design Work

For any frontend, UI, UX, or visual change:

1. Use `/frontend-design` when available — it provides screenshot-driven review, responsive checks, and accessibility basics.
2. Capture screenshots of:
   - Default / desktop state
   - Mobile / narrow viewport state (if applicable)
   - Loading, error, and empty states (if applicable)
3. Check responsive behavior where practical.
4. Check accessibility basics (keyboard nav, contrast, focus) where practical.
5. Compare against intended UX direction or design spec.

---

## Storing Artifacts

Store all demo artifacts in:

```
.agents/artifacts/
```

Use descriptive filenames:

```
.agents/artifacts/YYYY-MM-DD-<feature-id>-<state>.png
.agents/artifacts/YYYY-MM-DD-<feature-id>-mobile.png
.agents/artifacts/YYYY-MM-DD-<feature-id>-flow.gif
.agents/artifacts/YYYY-MM-DD-<feature-id>-test-output.txt
```

<!-- FILL: Add project-specific artifact storage paths if the project uses a different convention (e.g., /docs/screenshots, /test-results) -->

---

## Files to Update on Completion

After capturing evidence, update all of the following:

### 1. `feature_list.json` (repo root)

Set `status` to `"passing"` and add evidence references:

```json
{
  "id": "feature-id",
  "status": "passing",
  "evidence": [
    ".agents/artifacts/YYYY-MM-DD-feature-id-screenshot.png",
    "Test suite: all 42 tests passed"
  ]
}
```

### 2. `.agents/logs/changelog.md`

Add an entry under the current date:

```md
## YYYY-MM-DD

### Added
- Feature title — brief description of what changed (#issue-number)
```

See [../logs/changelog.md](../logs/changelog.md).

### 3. `.agents/logs/verification.md`

Record what was verified and how:

```md
## YYYY-MM-DD — Feature Title

### Commands Run
- `{{TEST_CMD}}` — passed (X tests)
- `{{BUILD_CMD}}` — success

### Evidence
- Screenshot: `.agents/artifacts/YYYY-MM-DD-feature-id.png`
- Test output: all assertions passed

### Remaining Risk
None / describe any risk that could not be verified.
```

See [../logs/verification.md](../logs/verification.md).

### 4. `.agents/logs/progress.md`

Move the feature from "In Progress" to "Completed" and update "Next Best Action".

See [../logs/progress.md](../logs/progress.md).

### 5. GitHub Issue / PR

- Comment with evidence (screenshot or test output).
- Use auto-closing keyword in PR body: `Closes #123`.
- Apply `needs-verification` label removal after evidence is attached.
- Apply `status: review` label if awaiting human review.

See [github-issues.md](./github-issues.md).

---

## If No Demo Can Be Created

Document the reason explicitly:

```md
## Demo Status — YYYY-MM-DD — Feature Title

### Why No Demo
Explain: headless environment, auth required, third-party dependency, etc.

### Alternate Evidence
- `{{TEST_CMD}}` output: all X tests passed
- `{{BUILD_CMD}}`: success, no errors
- Code review confirms expected behavior

### Remaining Risk
Describe what remains unverified and the risk level.
```

Never claim a demo exists when one was not produced.

---

## Quick Checklist

Before declaring a feature done:

- [ ] Evidence captured and stored in `.agents/artifacts/`
- [ ] `feature_list.json` updated to `"passing"` with evidence references
- [ ] `changelog.md` updated
- [ ] `verification.md` updated
- [ ] `progress.md` updated
- [ ] GitHub Issue / PR updated with evidence
- [ ] `/frontend-design` used for UI/UX changes (if available)
- [ ] No fabricated or assumed evidence

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
