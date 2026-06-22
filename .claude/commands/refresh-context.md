---
description: Audit context files against the real tree and fix drift
argument-hint: "[directory]"
---

# /refresh-context

> Detect and repair drift between what context files claim and what the directory actually contains.

## Purpose

Use this when context files — `repo-map.md`, `slash-commands.md`, `skills.md`, `AGENTS.md`, and related docs — fall out of sync with the real file tree. Drift accumulates after renames, moves, deletions, or bulk additions. Audits claims, patches stale references, verifies link resolution, and logs what changed.

Target directory: **$ARGUMENTS** (defaults to the full harness tree if omitted).

## Usage

`/refresh-context [directory]` — e.g. `/refresh-context .agents/context` or `/refresh-context` (whole tree).

## Preconditions

- Repo state is known (`git status`); on a feature branch or worktree before making edits.
- `scripts/verify-harness.sh` is executable.
- Read: [`AGENTS.md`](../../AGENTS.md), [`.agents/context/repo-map.md`](../../.agents/context/repo-map.md).

## Procedure

Scope the audit, produce three drift lists (added / moved / deleted), patch stale references, verify with `verify-harness.sh`, record in changelog. Full procedure and patch rules: [`.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md).

## Stop Conditions

Success: all drift resolved, `verify-harness.sh` exits cleanly, changelog updated. Stop and ask: a moved/deleted file is ambiguous or patching would conflict with in-progress work on another branch.

## Safety

Do not delete content speculatively — verify before removing any link. Do not commit or push; leave that to the caller. Never echo or log secret values found in context files.

## Output

Emits a Context Drift report (added / moved / deleted counts, patches applied table, verify-harness.sh result, changelog entry). Full procedure and patch rules: [`.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md).

## Related

- **Skills:** [`documentation-maintenance`](../../.claude/skills/documentation-maintenance/SKILL.md)
- **Workflows:** [`context-mapping.md`](../../.agents/workflows/context-mapping.md)
- **Commands:** `/context-map`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
