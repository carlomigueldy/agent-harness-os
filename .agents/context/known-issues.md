# Known Issues

Running list of known bugs, limitations, and workarounds. Updated as issues are discovered or resolved.

## Entry Format

Each entry follows this structure:

```
### [AREA] Title
- **Impact:** High / Medium / Low
- **Workaround:** What to do in the meantime.
- **Tracking:** Link to GitHub issue, if one exists.
```

---

## Active Issues

— no known issues yet —

<!-- FILL: Add issues as they are discovered during development or harness initialization. -->

> TEMPLATE NOTE: Seed this file during the initial harness discovery pass. Common early entries:
> - Flaky tests in CI
> - Missing env variable documentation
> - Commands that fail on certain OS versions
> - Stale or broken setup steps
> - Workaround required for a specific dependency version

---

## Recently Resolved

<!-- FILL: Move resolved entries here with a "Resolved: YYYY-MM-DD" note. This preserves history without cluttering the active list. -->

— none yet —

---

## How to Add a New Entry

When you discover a new issue during a session:

1. Add an entry to **Active Issues** above using the format shown.
2. If a GitHub issue exists or should be created, link it in the `Tracking` field.
3. Update `../logs/progress.md` to note the blocker if it is task-blocking.
4. If the issue is a harness gap (missing doc, wrong command, broken workflow), create a proposal in `../proposals/`.

## How to Resolve an Entry

When an issue is fixed:

1. Move it from **Active Issues** to **Recently Resolved**.
2. Add `Resolved: YYYY-MM-DD` and a one-line note on the fix.
3. Update `../logs/changelog.md` if the fix was a real code or harness change.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
