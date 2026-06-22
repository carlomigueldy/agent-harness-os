---
description: Pre-release checklist: verify, changelog, clean state
---

# /release-check

> Run the pre-release gate: full verification, changelog accuracy, clean-state checklist, and compliance (no secrets/attribution) before any tag or publish action.

## Purpose

Use this before tagging a release, cutting a version bump PR, or publishing a package. Enforces the harness's release gate: all verification commands pass, the changelog is accurate and up to date, no secrets are staged, and no AI/LLM attribution appears in any artifact. Emits a go/no-go summary with evidence so the release decision is auditable.

## Usage

`/release-check` — no arguments. Run from the release branch or worktree representing the version being shipped.

## Preconditions

- On the release branch or worktree (not `main`/`master`), or explicit approval to run on trunk.
- `verify-harness.sh` is executable (if present).
- Verification commands documented in [`.agents/context/commands.md`](../../.agents/context/commands.md).
- A changelog file exists at the project root.

## Procedure

Run `verify-harness.sh`, run project verification commands, confirm changelog accuracy, run the clean-state checklist, scan for secrets and AI attribution, emit verdict. Full procedure: [`.agents/workflows/release.md`](../../.agents/workflows/release.md).

## Stop Conditions

GO: all checks pass, changelog accurate, clean state, no secrets, no attribution. NO-GO immediately on any verification failure, secret found, or attribution found. Escalate on ambiguous version or force-push remediation.

## Safety

- Never tag, publish, or push a version without a GO verdict and explicit human approval.
- Never echo or log secret values — report only that a pattern was found and where.
- Confirm before any outward-facing action (tag push, package publish, GitHub release creation).

## Output

Emits a Release Check report (verification table, changelog status, clean-state checks, compliance checks, Verdict: GO / NO-GO, blockers). Full procedure and gate rules: [`.agents/workflows/release.md`](../../.agents/workflows/release.md). Skill: [`release-readiness`](../../.claude/skills/release-readiness/SKILL.md).

## Related

- **Skills:** [`release-readiness`](../../.claude/skills/release-readiness/SKILL.md)
- **Workflows:** [`release.md`](../../.agents/workflows/release.md)
- **Commands:** `/final-handoff`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
