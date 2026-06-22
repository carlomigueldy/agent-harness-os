---
description: Security review of pending changes; log findings
argument-hint: "[scope]"
model: opus
---

# /security-review

> Scan pending changes for secrets, weakened security controls, injection vectors, and unguarded automation; record every finding and emit a verdict.

## Purpose

Use this before merging any change that touches auth, validation, rate limits, automation loops, migrations, infra, or secrets handling. Enforces the Never-list so nothing ships with a security regression. Run after implementation and before `/review-10x` when the change has any security surface.

Scope: **$ARGUMENTS** (leave empty to review the full pending diff).

## Usage

`/security-review` — review all staged and unstaged changes.

`/security-review <scope>` — e.g. `/security-review src/auth` or `/security-review HEAD~3..HEAD`.

## Preconditions

- On a feature branch or worktree, not `main`/`master`.
- `git diff` produces non-empty output; if the diff is empty, report and exit.
- [`AGENTS.md`](../../AGENTS.md) and [`CLAUDE.md`](../../CLAUDE.md) read this session for project-specific security context.

## Procedure

Collect the diff, scan for secrets and tracked env files, check the Never-list (authz/validation/rate-limits/destructive-ops/untrusted-input), verify loop bounds and gates, log and emit verdict. Full procedure: [`security-review`](../../.claude/skills/security-review/SKILL.md). Workflow: [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Stop Conditions

PASS on Minor/Nit only; REVISE on Major; BLOCK on Critical — escalate immediately, do not auto-fix. Abort if diff is empty. See [`evaluator-rubric.md`](../../evaluator-rubric.md).

## Safety

- Never echo or quote a discovered secret value — reference by file + line number only.
- Never attempt auto-remediation; this command is review-only. Surface findings for a separate fix step.
- Stop and escalate on Critical findings involving on-chain writes, payment logic, prod credentials, or auth bypass — do not attempt autonomous fixes.

## Output

Emits a Security Review report (verdict, finding count table, findings by severity, checked checklist) and appends to [`.agents/logs/failures.md`](../../.agents/logs/failures.md) and [`.agents/logs/verification.md`](../../.agents/logs/verification.md). Verdict rules (PASS/REVISE/BLOCK) and severity definitions: [`evaluator-rubric.md`](../../evaluator-rubric.md). Skill: [`security-review`](../../.claude/skills/security-review/SKILL.md). Full review workflow: [`.agents/workflows/review.md`](../../.agents/workflows/review.md).

## Related

- **Skills:** [`security-review`](../../.claude/skills/security-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md)
- **Commands:** `/review-10x`, `/gated-orchestration`, `/review-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
