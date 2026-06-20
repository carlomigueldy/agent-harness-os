---
description: Security review of pending changes; log findings
argument-hint: "[scope]"
model: opus
---

# /security-review

> Scan pending changes for secrets, weakened security controls, injection vectors, and unguarded automation; record every finding and emit a verdict.

## Purpose

Use this before merging any change that touches auth, validation, rate limits, automation loops, migrations, infra, or secrets handling. It enforces the harness's security doctrine — the Never-list — so nothing ships with a security regression. Run it after implementation and before `/review-10x` when the change has any security surface.

Scope: **$ARGUMENTS** (leave empty to review the full pending diff).

## Usage

`/security-review` — review all staged and unstaged changes in the working tree.

`/security-review <scope>` — e.g. `/security-review src/auth` or `/security-review HEAD~3..HEAD`.

## Parameters

- `$ARGUMENTS` (optional) — a path, glob, or git revision range to limit the review scope. Defaults to the full `git diff HEAD` when omitted.

## Preconditions

- You are on a feature branch or worktree; never reviewing directly on `main`/`master`.
- `git diff` (or the scoped equivalent) is available and produces non-empty output; if the diff is empty, report that and exit.
- [`AGENTS.md`](../../AGENTS.md) and [`CLAUDE.md`](../../CLAUDE.md) have been read this session so project-specific security context is loaded.

## Procedure

1. **Collect the diff.** Run `git diff HEAD -- $ARGUMENTS` (or `git diff $ARGUMENTS` if a revision range is supplied). If the diff is empty, report "No pending changes in scope — nothing to review." and stop. Capture the full diff text for analysis in the steps below.

2. **Scan for secrets and tracked env files.**
   - Search every added or modified line (`+` prefix) for patterns that indicate secrets: API keys, tokens, passwords, private keys, connection strings, bearer credentials, and base64-encoded blobs that look like key material.
   - Check whether any `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, or credential files are staged or modified. If any are tracked (not listed in `.gitignore`), flag as **Critical**.
   - Check `git log --diff-filter=A -- '*.env*' '*.key' '*.pem'` to catch newly tracked secret files.
   - Never echo or quote a discovered secret value in findings — reference it by file + line number only.

3. **Check the Never-list — authz, validation, rate limits, destructive ops, untrusted input.**
   - **Authentication / authorisation:** look for removed or bypassed auth guards, permission checks, role assertions, or middleware. Any weakening is **Critical**.
   - **Input validation:** look for removed validators, added `any` / untyped casts on external input, disabled schema checks, or direct interpolation of user-supplied values into queries, shell commands, file paths, or template strings. Flag injection vectors (SQL, command, path, template) as **Critical**.
   - **Rate limits:** look for removed or commented-out rate-limit decorators, middleware, or checks. Flag as **Major**.
   - **Destructive operations without gates:** look for deletes, truncates, migrations, drops, or `rm -rf` patterns that execute without an explicit confirmation gate or dry-run flag. Flag as **Major** or **Critical** depending on blast radius.
   - **Untrusted input propagation:** trace any new data path that takes external input (HTTP body, query params, env vars, file uploads, webhook payloads) and verify it is validated and sanitised before use. Flag unvalidated propagation as **Critical** or **Major**.

4. **Verify autonomous loops are bounded and destructive actions are confirmation-gated.**
   - Identify any new or modified automation loop, cron, background worker, or agentic workflow in the diff.
   - Confirm each loop has an explicit iteration cap or timeout — no unbounded `while True` / infinite recursion without a break condition. Missing caps are **Major**.
   - Confirm every destructive or outward-facing action inside a loop (API writes, sends, deletes, on-chain transactions) is guarded by a human-in-the-loop confirmation gate or a dry-run flag. Missing gate is **Critical**.
   - Check that no loop silently swallows errors — at minimum errors must be logged. Silent error suppression is **Minor**.

5. **Log findings and emit a verdict.**
   - Append a structured finding block to [`../../.agents/logs/failures.md`](../../.agents/logs/failures.md) (one entry per finding, with severity, file, line reference, and remediation hint).
   - Append a summary entry to [`../../.agents/logs/verification.md`](../../.agents/logs/verification.md) recording the scope, timestamp, finding counts by severity, and verdict.
   - Emit the security-review report (see **Output**).

## Stop Conditions

- **Success:** all checks completed, findings logged, verdict emitted.
- **Stop and escalate:** a **Critical** finding involving on-chain writes, payment logic, prod credentials, or auth bypass — stop, do not attempt an autonomous fix; surface the finding to the human owner for a decision before proceeding.
- **Abort:** the diff is empty or the scope resolves to no files; report this and exit cleanly.
- Never attempt to auto-commit a fix found during a security review without explicit instruction — record the finding and let the implementation agent handle it in a separate step.

## Safety

- **Never echo secret values.** Reference secrets by file path and line number only — never quote the actual value in findings, logs, commits, or messages.
- **No AI/LLM attribution** in log entries, commit messages, or any output artifact.
- Do not weaken or remove a security control to make a check pass — that is itself a **Critical** finding.
- Confirm before taking any automated remediation action; this command is review-only by default.
- Treat all external / user-supplied input encountered in the diff as untrusted.

## Output

Emit a security-review report immediately after completing the procedure:

```md
## Security Review — <scope or "full diff">

**Verdict:** PASS | REVISE | BLOCK

| Severity | Count |
|---|---|
| Critical | N |
| Major | N |
| Minor | N |
| Nit | N |

### Findings

#### [Critical] <short title> — <file>:<line>
> <what the problem is and why it matters>
Remediation: <one-line fix hint>

#### [Major] ...

### Checked
- [ ] Secrets / tracked env files
- [ ] Authz / permission guards
- [ ] Input validation / injection vectors
- [ ] Rate limits
- [ ] Destructive ops gating
- [ ] Untrusted input propagation
- [ ] Loop bounds and destructive-action gates

### Logged
- Findings: `.agents/logs/failures.md`
- Summary: `.agents/logs/verification.md`
```

**Verdict rules** (same vocabulary as the rest of the harness — see [`review.md`](../../.agents/workflows/review.md)):
- `BLOCK` — one or more Critical findings; must be resolved before merge.
- `REVISE` — one or more Major findings with no Critical; resolve before merge.
- `PASS` — only Minor / Nit findings or none; safe to proceed to `/review-10x`.

## Related

- **Skills:** [`opus-code-review`](../../.claude/skills/opus-code-review/SKILL.md)
- **Workflows:** [`review.md`](../../.agents/workflows/review.md)
- **Commands:** `/review-10x`, `/gated-orchestration`, `/review-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
