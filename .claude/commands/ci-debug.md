---
description: Diagnose a failing CI run; root-cause and fix
argument-hint: "[run-url-or-log]"
---

# /ci-debug

> Diagnose why a CI run failed, reproduce it locally, and fix the root cause.

## Purpose

Use this when a CI run is red and you need to go from "something broke in CI" to a verified local fix. It enforces a disciplined read → reproduce → root-cause → fix → confirm loop so you never guess-and-push.

Run target: **$ARGUMENTS**

## Usage

`/ci-debug [run-url-or-log]` — e.g. `/ci-debug https://github.com/{{ORG}}/{{REPO}}/actions/runs/12345678` or `/ci-debug .agents/logs/ci-failures.md`.

If `$ARGUMENTS` is empty, ask for the run URL or paste the relevant log excerpt before proceeding.

## Parameters

- `$ARGUMENTS` (optional) — a CI run URL, a path to a captured log file, or a pasted log excerpt. If omitted, prompt for it.

## Preconditions

- You are on the correct branch or worktree associated with the failing run.
- The CI workflow file (`.github/workflows/*.yml` or equivalent) is readable in the working tree.
- `verify-harness.sh` (or the project's verification entrypoint) is present and executable.
- Local environment variables required to run CI checks are available (check [`.agents/context/commands.md`](../../.agents/context/commands.md) for the verification command list).

## Procedure

1. **Read the failure.** Fetch or open `$ARGUMENTS`. Extract the failing job name, the failing step, and the exact error message or non-zero exit code. If a run URL is given, retrieve the raw log for the failing step. Also read the CI workflow file to understand the full job graph and the environment it sets up.

2. **Read the harness verification script.** Open `verify-harness.sh` (or the project's equivalent entrypoint). Identify which check maps to the failing CI step. Note any environment flags, working-directory assumptions, or tool-version pins the script relies on.

3. **Reproduce locally.** Run the exact command the failing CI step executes — do not skip steps. Match the environment as closely as possible (clean node_modules / venv / build cache if CI does a clean install). Confirm you can reproduce the same error output locally before proceeding.

4. **Root-cause.** Apply the debugging workflow in [`.agents/workflows/debugging.md`](../../.agents/workflows/debugging.md): narrow the blast radius, form a hypothesis, test it with the smallest possible change. Common CI failure classes to rule out in order: missing or mismatched dependency version; environment variable absent locally but present in CI (or vice-versa); file not committed / `.gitignore` exclusion; race condition or test-ordering dependency; stale lock file or cache artifact.

5. **Apply a targeted fix.** Make the minimal change that addresses the root cause — no unrelated cleanup in the same commit. Confirm the fix does not introduce secrets, weaken validation, or break other checks.

6. **Re-run locally to confirm green.** Execute `verify-harness.sh` (or the same command CI runs) end-to-end. Every check must pass before you proceed. If a check cannot be run locally, document exactly why and what the residual risk is.

7. **Record the fix.** Append a structured entry to `.agents/logs/ci-failures.md` (create the file if absent) with: date, run reference, failing step, root cause, fix applied, verification evidence. If the project maintains a `CHANGELOG.md` or similar, note the fix there per project convention.

## Stop Conditions

- **Success:** local verification passes end-to-end; fix recorded in the failures log; ready to commit and push.
- **Escalate / stop and ask:** root cause requires a dependency upgrade, infrastructure change, or secret rotation that is outward-facing or irreversible — surface the finding and wait for approval before acting.
- **Block:** cannot reproduce locally and the gap cannot be explained — document what was tried, what differs, and open a follow-up issue rather than pushing a speculative fix.
- Do not iterate more than **6 hypothesis/fix cycles** without a checkpoint; if still failing, document findings and escalate.

## Safety

- Never commit or echo secrets, tokens, or credentials — even as temporary debug values.
- Confirm before force-pushing, reverting commits, or modifying shared branches.
- Do not weaken lint rules, skip test suites, or lower coverage thresholds to make CI green — fix the underlying problem.
- No AI/LLM attribution in any commit, PR description, or comment.
- If the fix touches auth, migrations, contracts, or infrastructure, treat it as high-risk and apply the security checklist in [`.agents/context/commands.md`](../../.agents/context/commands.md).

## Output

Emit a CI debug report:

```md
## CI Debug — <failing job / step>

- Run: <URL or log reference>
- Failing step: <job > step name>
- Error: <exact error / exit code>
- Root cause: <one sentence>
- Fix applied: <file(s) changed + description>
- Verification: <command run> → <PASS / output snippet>
- Failures log: <path to entry>
- Follow-ups: <any residual issues or open questions>
```

## Related

- **Skills:** [`test-debugging`](../../.claude/skills/test-debugging/SKILL.md)
- **Workflows:** [`testing.md`](../../.agents/workflows/testing.md), [`debugging.md`](../../.agents/workflows/debugging.md)
- **Commands:** `/fix-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
