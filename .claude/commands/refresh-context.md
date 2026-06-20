---
description: Audit context files against the real tree and fix drift
argument-hint: "[directory]"
---

# /refresh-context

> Detect and repair drift between what context files claim and what the directory actually contains.

## Purpose

Use this when context files — `repo-map.md`, `slash-commands.md`, `skills.md`, `AGENTS.md`, and related docs — fall out of sync with the real file tree. Drift accumulates after renames, moves, deletions, or bulk additions. This command audits the claims, patches the stale references, verifies link resolution, and logs what changed.

Target directory: **$ARGUMENTS** (defaults to the full harness tree if omitted).

## Usage

`/refresh-context [directory]` — e.g. `/refresh-context .agents/context` or `/refresh-context` (whole tree).

## Parameters

- `$ARGUMENTS` (optional) — a path to scope the audit. When omitted, audit the entire harness (`.agents/`, `.claude/`, root context files). When provided, restrict the diff and patch steps to that subtree.

## Preconditions

- Repo state is known (`git status`). The working tree should be on a feature branch or worktree, not the default branch, before making edits.
- `scripts/verify-harness.sh` is executable (`chmod +x scripts/verify-harness.sh` if needed).
- The relevant context has been read: [`AGENTS.md`](../../AGENTS.md), [`../../.agents/context/repo-map.md`](../../.agents/context/repo-map.md).

## Procedure

1. **Scope the audit.** If `$ARGUMENTS` is provided, set the root to that path; otherwise default to the harness root. Run `find <root> -type f -name "*.md" | sort` to capture the real file tree. Separately collect all file paths referenced (as links or plain paths) in these context files: `.agents/context/repo-map.md`, `.agents/context/slash-commands.md`, `.agents/context/skills.md`, `.agents/context/architecture.md`, `AGENTS.md`, `CLAUDE.md`. Produce three lists:
   - **Added** — files present on disk but not mentioned in context docs.
   - **Moved** — files whose names appear in context docs but at a different path on disk.
   - **Deleted** — files referenced in context docs that no longer exist on disk.

2. **Patch stale references.** For each discrepancy from Step 1:
   - **Deleted** — remove or comment out every reference (links, table rows, inline mentions). Do not leave dangling links whose target file no longer exists.
   - **Moved** — update every link target to the new path. Verify the new path resolves before saving.
   - **Added** — decide whether the new file belongs in the context index. If yes, add a row or entry in the appropriate context doc (`repo-map.md`, `slash-commands.md`, or `skills.md`). If the file is ephemeral or private, note the omission reason in the changelog (Step 4).
   Also sweep for: stale `{{PLACEHOLDER}}` values that have been filled in elsewhere but not here; length limits exceeded (files over the documented line cap); and rules or conventions that reference removed patterns.

3. **Verify link resolution and harness integrity.** Run `bash scripts/verify-harness.sh` from the repo root. Confirm all checks pass. If any check fails, diagnose and fix before proceeding. Re-run until the script exits cleanly. Do not mark this step done by assertion — show the script output as evidence.

4. **Record non-trivial corrections in the changelog.** Open [`../../.agents/logs/changelog.md`](../../.agents/logs/changelog.md) and append a dated entry under today's date. Include: which context files were patched, a count of deleted / moved / added references resolved, and any files intentionally left out of the index with the reason. Skip trivial whitespace-only corrections. If zero changes were needed, append a brief "no drift found" note so the audit is traceable.

## Stop Conditions

- **Success:** all three drift lists are empty (or resolved), `verify-harness.sh` exits cleanly, changelog updated with evidence.
- **Stop and ask:** a moved or deleted file is ambiguous — you cannot determine the intended new path or whether it was intentionally removed. Surface the specific ambiguity before patching.
- **Stop and ask:** patching would require editing a file outside the scoped directory in a way that may conflict with in-progress work on another branch.

## Safety

- Do not delete content speculatively. If a referenced file might exist under a different name, check before removing the link.
- Do not commit or push — leave that to the caller.
- Never echo or log secret values; context files sometimes reference `.env` paths. Reference the path name only.
- No AI/LLM attribution in any edited file or changelog entry.

## Output

Emit a context-drift report after completing all steps:

```md
## Context Drift Report — <scope>

### Diff summary
- Added (on disk, not in context): <count> — <list or "none">
- Moved (path changed): <count> — <list or "none">
- Deleted (referenced, not on disk): <count> — <list or "none">

### Patches applied
| File patched | Change type | Details |
|---|---|---|
| <context file> | deleted ref / moved ref / added entry | <brief note> |

### Verification
`bash scripts/verify-harness.sh` — <PASS / FAIL + output excerpt>

### Changelog
Appended to `.agents/logs/changelog.md` — <date, entry summary>
```

## Related

- **Workflows:** [`context-mapping.md`](../../.agents/workflows/context-mapping.md)
- **Commands:** `/context-map`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
