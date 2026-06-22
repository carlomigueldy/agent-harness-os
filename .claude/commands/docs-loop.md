---
description: Update docs until accurate and links resolve (max 4)
argument-hint: "[docs-scope]"
---

# /docs-loop

> Bring docs in line with reality: accurate content, resolving links, and within entry-file length limits — bounded at 4 iterations.

## Purpose

Use this when documentation has drifted from the codebase: stale descriptions, broken relative links, or files that exceed the entry-file length limits enforced by `verify-harness.sh`. Max **4 iterations**.

Scope: **$ARGUMENTS** (defaults to the full `.agents/` and `.claude/` doc tree if omitted).

## Usage

`/docs-loop [docs-scope]` — e.g. `/docs-loop .agents/context` or `/docs-loop AGENTS.md CLAUDE.md`.

## Preconditions

- On a feature branch or worktree, not the default branch.
- `bash scripts/verify-harness.sh` is executable at the repo root.
- Relevant context read: [`AGENTS.md`](../../AGENTS.md), [`CLAUDE.md`](../../CLAUDE.md).

## Procedure

Scan for stale content and broken links, fix them, run `bash scripts/verify-harness.sh`, repeat. Full schema: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Stop Conditions

`verify-harness.sh` exits 0 with no failures; CAP at 4 iterations — document remaining issues, create follow-up. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Never weaken or remove safety, attribution, or classification notes. Scope to docs only — do not edit source or configs as a side effect.

## Output

Emits a Docs Loop report. Schema, stop conditions, safety rules, and report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Related

- **Skills:** [`documentation-maintenance`](../../.claude/skills/documentation-maintenance/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/refresh-context`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
