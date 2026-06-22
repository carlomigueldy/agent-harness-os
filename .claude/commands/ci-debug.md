---
description: Diagnose a failing CI run; root-cause and fix
argument-hint: "[run-url-or-log]"
---

# /ci-debug

> Diagnose why a CI run failed, reproduce it locally, and fix the root cause.

## Purpose

Use this when a CI run is red and you need to go from "something broke in CI" to a verified local fix. Enforces read → reproduce → root-cause → fix → confirm discipline. Never guess-and-push.

Run target: **$ARGUMENTS**

## Usage

`/ci-debug [run-url-or-log]` — e.g. `/ci-debug https://github.com/{{ORG}}/{{REPO}}/actions/runs/12345678` or `/ci-debug .agents/logs/ci-failures.md`.

If `$ARGUMENTS` is empty, ask for the run URL or log excerpt before proceeding.

## Preconditions

- On the correct branch or worktree associated with the failing run.
- The CI workflow file (`.github/workflows/*.yml` or equivalent) is readable.
- `verify-harness.sh` (or the project's verification entrypoint) is present and executable.
- Local environment variables confirmed from [`.agents/context/commands.md`](../../.agents/context/commands.md).

## Procedure

Read the failure log, reproduce locally, root-cause, apply minimal fix, re-run verification end-to-end, record in `.agents/logs/ci-failures.md`. Full methodology: [`test-debugging`](../../.claude/skills/test-debugging/SKILL.md) + [`.agents/workflows/debugging.md`](../../.agents/workflows/debugging.md).

## Stop Conditions

Local verification passes end-to-end; escalate if root cause requires infra/secret rotation; BLOCK if cannot reproduce and gap is unexplained. Max 6 hypothesis/fix cycles.

## Safety

Never commit or echo secrets; confirm before force-pushing or reverting commits. Do not skip test suites or lower coverage thresholds to make CI green.

## Output

Emits a CI Debug report (run reference, failing step, error, root cause, fix, verification result, failures log path). Procedure and debugging methodology: [`.agents/workflows/debugging.md`](../../.agents/workflows/debugging.md). Test verification: [`.agents/workflows/testing.md`](../../.agents/workflows/testing.md). Skill: [`test-debugging`](../../.claude/skills/test-debugging/SKILL.md).

## Related

- **Skills:** [`test-debugging`](../../.claude/skills/test-debugging/SKILL.md)
- **Workflows:** [`testing.md`](../../.agents/workflows/testing.md), [`debugging.md`](../../.agents/workflows/debugging.md)
- **Commands:** `/fix-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
