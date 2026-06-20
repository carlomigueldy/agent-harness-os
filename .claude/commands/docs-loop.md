---
description: Update docs until accurate and links resolve (max 4)
argument-hint: "[docs-scope]"
---

# /docs-loop

> Bring docs in line with reality: accurate content, resolving links, and within entry-file length limits — bounded at 4 iterations.

## Purpose

Use this when documentation has drifted from the codebase: stale descriptions, broken relative links, or files that exceed the entry-file length limits enforced by `verify-harness.sh`. The loop runs up to 4 times, checking and fixing until the harness verification passes clean.

Scope: **$ARGUMENTS** (defaults to the full `.agents/` and `.claude/` doc tree if omitted).

## Usage

`/docs-loop [docs-scope]` — e.g. `/docs-loop .agents/context` or `/docs-loop AGENTS.md CLAUDE.md`.

## Parameters

- `$ARGUMENTS` (optional) — one or more paths, files, or globs to restrict the scope. If omitted, the full harness doc tree (`.agents/`, `.claude/`, root entry files) is used.

## Preconditions

- Repo state is understood (`git status`); you are on a feature branch or worktree, not the default branch.
- `bash scripts/verify-harness.sh` is executable and available at the repo root.
- The relevant context has been read: [`AGENTS.md`](../../AGENTS.md), [`CLAUDE.md`](../../CLAUDE.md).

## Procedure

1. **Identify stale or missing content.** Scan every file in $ARGUMENTS (or the full doc tree if no scope was given). For each file, check: does the content reflect the current directory structure, feature list, and workflow names? Are any descriptions, file references, or section summaries out of date? Produce a triage list — file path, what is stale/missing, severity (broken link | wrong content | length violation).

2. **Update content; fix broken relative links.** For each item in the triage list: rewrite stale content to match reality; fix every broken relative link to use the correct path anchored from the file's location; trim or restructure any file that exceeds its entry-file length limit (`AGENTS.md` ≤ 200 lines, `CLAUDE.md` ≤ 250 lines). Do not add filler — cut, consolidate, or move detail to a deeper doc instead. Record each fix as a one-liner in a running change log.

3. **Run `bash scripts/verify-harness.sh` and capture output.** Parse results: count passes, failures, and warnings. For each failure, map it back to a specific file and line. If all checks pass, proceed to the Stop Conditions check. If failures remain, go to step 4.

4. **Repeat.** Fix the failures surfaced in step 3, then re-run `bash scripts/verify-harness.sh`. Increment the iteration counter. Stop when verification is clean or the iteration cap of 4 is reached — whichever comes first.

## Stop Conditions

- **Success:** `bash scripts/verify-harness.sh` exits 0 with no failures; all targeted docs are accurate and links resolve.
- **Cap reached:** 4 iterations completed and failures remain — stop, document what is still broken, create a follow-up issue, and surface the unresolved items in the output report.
- **Blocked:** a fix requires a structural decision (e.g., renaming a workflow file, reorganising the doc tree) that is irreversible or outward-facing with no safe default — stop and ask before proceeding.
- Never loop past 4 iterations. See [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) for the loop system and iteration-cap rationale.

## Safety

- Do not commit changes automatically — leave that to the human or to `/commit` after review.
- Never weaken or remove safety, attribution, or classification notes from docs.
- No AI/LLM attribution in any file you touch — not in content, comments, or commit messages.
- Do not echo secret values; if a doc references a secret pattern, describe the pattern, never the value.
- Scope changes to docs only — do not edit source code, configs, or scripts as a side effect.

## Output

Emit a docs-loop report after the final iteration:

```md
## Docs Loop — <scope>
- Iterations: <n> / 4
- Files changed: <list>
- Fixes applied: <change log — one line per fix>
- verify-harness.sh: <PASS | FAIL — N failures>
- Remaining issues: <none | list with file + description>
- Follow-ups: <issue links or "none">
```

## Related

- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/refresh-context`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
