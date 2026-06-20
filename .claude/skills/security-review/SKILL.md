---
name: security-review
description: Review changes for staged secrets, weakened authz/validation/rate-limits, injection, and unsafe automation; log findings
---

# Skill: security-review

## Purpose

Find security problems in a change before it ships: leaked secrets, weakened controls, injection surfaces, and unsafe automation. This is the safety review gate — it runs before any change touching auth, payments, secrets, migrations, prod infra, or destructive/autonomous actions is considered shippable. Pair it with [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) for a complete quality + safety pass; never use it as a substitute for the full review.

## When to Use

- Any change that touches auth, authorization, or permission checks.
- Changes to payment, wallet, or financial logic.
- Anything that reads, writes, or references secrets or environment variables.
- Database migrations, destructive operations, or production infrastructure changes.
- New or modified autonomous loops, cron jobs, or agent-driven workflows.
- Changes in CI/CD pipelines where injection or credential exposure is possible.
- The safety gate step in [`../../../.agents/workflows/review.md`](../../../.agents/workflows/review.md).

## When Not to Use

- As a substitute for [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) — always pair them; security-review narrows a specific risk surface, it does not replace a full rubric pass.
- Pure documentation changes with no code, config, or executable surface.
- Trivial formatting or whitespace-only diffs where no logic changed.

## Inputs

- The diff, PR, branch, or set of files to review.
- The context about what the change is supposed to do (issue, acceptance criteria, sprint contract).
- Access to the project's secret-pattern list or `.gitignore` / `.env.example` to confirm what should never be tracked.

## Outputs

- A **Security Review Result** block recorded in [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md) or inline in the PR, containing:
  - Verdict: `PASS` / `REVISE` / `BLOCK`
  - Findings categorized as Critical / Major / Minor / Nit
  - Each finding with file, line or location, description, and remediation

## Procedure

1. **Scan the diff for secret patterns and tracked env files.**
   - Search for API keys, tokens, passwords, private keys, and connection strings committed to tracked files.
   - Common patterns: `sk-`, `ghp_`, `AKIA`, `-----BEGIN`, `password =`, `secret =`, `token =`, base64-encoded blobs in config.
   - Confirm `.env`, `*.pem`, `*.key`, `*.p12`, and any file containing real credentials are in `.gitignore` and not staged.
   - If a secret is staged or committed: **Critical** — stop, do not proceed to other steps without flagging this.

2. **Check the Never-list: authz, input validation, rate limits, and permission checks.**
   - Verify that no auth or authorization check has been removed, relaxed, bypassed, or commented out.
   - Confirm that input validation (type, length, allowlist/denylist) has not been weakened or deleted for any user-controlled field.
   - Check that rate-limiting and throttling logic is not loosened or removed.
   - Confirm permission checks are still present and enforced at every sensitive entry point — not just at the UI layer.
   - Any weakening of these controls is **Critical**.

3. **Confirm destructive and outward-facing actions are confirmation-gated and loops are bounded.**
   - Destructive operations (deletes, drops, truncates, hard resets) must require explicit confirmation before executing — verify the gate is present and not bypassable.
   - Outward-facing actions (sending messages, publishing events, hitting external APIs, triggering webhooks) must be guarded — no fire-and-forget without approval gates in autonomous contexts.
   - Autonomous loops must have a documented stop condition, max-iteration bound, and escalation/abort path. A loop with no ceiling is **Major**.
   - On-chain or wallet WRITE operations require explicit go-ahead before execution — flag any that run unconditionally.

4. **Treat untrusted input as hostile; check handling end to end.**
   - Identify every point where user-controlled or externally-sourced data enters the system: HTTP bodies, query params, headers, file uploads, webhook payloads, CLI args, environment-injected values.
   - Verify each entry point sanitizes, escapes, or parameterizes before use — especially in SQL queries, shell commands, template rendering, file paths, and eval-adjacent calls.
   - Check for prototype pollution, path traversal (`../`), and command injection in {{PLACEHOLDER: language/framework-specific}} contexts.
   - Unvalidated input flowing into a sink (query, command, path, eval) is **Critical** (injection) or **Major** (improper handling without immediate sink risk).

5. **Log findings and emit a verdict.**
   - Record every finding with severity (Critical / Major / Minor / Nit), file + line or location, description, and a concrete remediation step.
   - A staged secret or weakened control is always **Critical** → verdict `BLOCK`.
   - One or more **Major** findings without a clear immediate fix → verdict `REVISE`.
   - Only **Minor** / **Nit** findings → verdict `PASS` with notes.
   - Zero findings and all checks clean → verdict `PASS`.
   - Write the result block to [`../../../.agents/logs/verification.md`](../../../.agents/logs/verification.md) or the PR comment thread.

## Checks

- Every Critical/Major finding cites a file and line or a concrete location — no vague "possible issue" claims.
- The staged-secret scan actually ran against the diff, not just a description of the diff.
- All five procedure steps were completed before emitting the verdict — do not shortcut to PASS after step 1 alone.
- No AI/LLM attribution was introduced anywhere in the change; no secret value was echoed in any finding or log.

## Common Failure Modes

- **Scanning only committed files, not the staged diff** — a secret can be staged without being in the last commit; always diff against `HEAD` or `--cached`.
- **Trusting descriptions over code** — "we removed the token" must be verified in the actual diff, not the PR description.
- **Treating a weakened check as Minor** — any removal or bypass of auth, validation, or rate-limiting is Critical regardless of intent.
- **Missing injection sinks in templating or ORMs** — parameterized queries protect SQL but not shell, file paths, or template engines; check all relevant sinks for the stack.
- **Skipping the loop-bounding check** — an autonomous loop without a stop condition is a runaway risk; it is easy to overlook if no secrets or auth changes are present.
- **Passing at REVISE when a staged secret is present** — a staged secret is always BLOCK, no exceptions.

## Example Usage

> A PR adds a new webhook handler that validates an HMAC signature and stores the payload. Running `security-review`: step 1 finds no staged secrets. Step 2 confirms the HMAC check is present and not bypassable. Step 3 confirms no destructive action is unconditional. Step 4 finds the raw webhook body is passed unsanitized to a shell command — **Critical injection**. Verdict: `BLOCK`. Fix: parameterize the shell call or reject unexpected characters. After fix, re-run → all five steps clean → verdict `PASS`. Result recorded in `verification.md`.

## Related Commands

`/security-review`, `/review-10x`

## Maintenance Notes

- When the project's secret patterns change (new provider, new key format), update step 1's pattern list or the project's `.gitignore` and note it here.
- When new destructive operations or autonomous loop types are added to the harness, add them to step 3's scope.
- Keep the severity thresholds in sync with [`../../../evaluator-rubric.md`](../../../evaluator-rubric.md) and the review gate in [`../../../.agents/workflows/review.md`](../../../.agents/workflows/review.md).
- The Never-list in step 2 mirrors the security doctrine in `../../../AGENTS.md` — if that doc changes, update step 2 to match.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
