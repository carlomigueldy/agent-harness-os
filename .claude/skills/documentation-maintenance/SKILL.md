---
name: documentation-maintenance
description: Keep docs accurate, cross-linked, and within entry-file length limits; fix broken relative links
---

# Skill: documentation-maintenance

## Purpose

Maintain harness documentation so it stays accurate, navigable, and within enforced length limits. This skill covers drift correction (content that no longer matches the code or workflow), broken relative link repair, and entry-file length enforcement — so that every session reads fresh, trustworthy context. For creating substantive new doctrine, use the authoring workflow instead; this skill only corrects what already exists.

## When to Use

- Docs drift from reality: a command, path, workflow step, or tool reference is stale.
- A relative link returns 404 — file moved, renamed, or deleted.
- `AGENTS.md` approaches 200 lines or `CLAUDE.md` approaches 250 lines and detail must be split out.
- The documentation review gate at the end of any harness change that touches context files.
- Running `/docs-loop` or `/refresh-context` and one of them surfaces stale or broken content.

## When Not to Use

- Writing new doctrine or designing a new workflow — that is authoring, not maintenance; use [`../skill-authoring/SKILL.md`](../skill-authoring/SKILL.md) or the workflow improvement process instead.
- When the docs are already verified accurate and all links pass — skip this skill entirely.
- For context file creation from scratch — use [`../context-mapping/SKILL.md`](../context-mapping/SKILL.md) instead.

## Inputs

- The doc files to audit (defaults: all `AGENTS.md`, `CLAUDE.md`, `.agents/context/*.md`, `.agents/workflows/*.md`, `.claude/skills/*/SKILL.md`).
- The current source-of-truth: code, directory listings, and live workflow behavior.
- Output of `scripts/verify-harness.sh` (link check + length check) if already run.

## Outputs

- Corrected doc files with accurate content and working relative links.
- `AGENTS.md` ≤ 200 lines, `CLAUDE.md` ≤ 250 lines — any overflows split into referenced detail docs.
- A brief entry appended to [`../../../.agents/logs/changelog.md`](../../../.agents/logs/changelog.md) recording non-trivial changes.
- A clean `scripts/verify-harness.sh` run (zero link errors, zero length violations).

## Procedure

1. **Identify stale content and broken links.**
   - Run `scripts/verify-harness.sh` and capture its output. Note every broken link and every length violation.
   - For each stale reference (commands, file paths, tool names, step counts), confirm the current source-of-truth by reading the relevant file or running `ls`/`find`. Do not guess.
   - Check cross-references between files: if a doc references another doc, confirm the target exists and the description matches its current content.

2. **Update content; fix links to correct relative paths.**
   - Correct stale prose — update file paths, command names, step numbers, tool references to match reality.
   - Fix broken relative links using the canonical prefix rules for each file's location:
     - From `.claude/skills/<name>/SKILL.md`: workflows → `../../../.agents/workflows/<file>.md`, context → `../../../.agents/context/<file>.md`, root files → `../../../<file>`, sibling skills → `../<name>/SKILL.md`.
     - From `.agents/context/*.md` or `.agents/workflows/*.md`: root files → `../../<file>`, skills → `../../.claude/skills/<name>/SKILL.md`.
   - Never use absolute paths or repo-root-relative paths — always relative from the file being edited.
   - If a link target was deleted and has no replacement, remove the link and update the surrounding prose.

3. **Enforce entry-file length limits.**
   - Count lines in `AGENTS.md` (limit: 200) and `CLAUDE.md` (limit: 250).
   - If either is over its limit, identify the detail that belongs in a context or workflow doc rather than the entry file.
   - Move that detail into the appropriate `.agents/context/<topic>.md` or `.agents/workflows/<topic>.md`, then replace it in the entry file with a one-line summary + relative link.
   - Re-count to confirm compliance.

4. **Run verify-harness.sh link and length checks.**
   - Execute `bash scripts/verify-harness.sh` from the repo root.
   - Address every reported error before declaring the skill done. Re-run until the output is clean.
   - If the script is unavailable, manually verify each link by confirming the target path exists with `ls` or `find`.

5. **Record non-trivial changes in the changelog.**
   - Append a concise entry to [`../../../.agents/logs/changelog.md`](../../../.agents/logs/changelog.md): what changed, why it drifted, and what was corrected.
   - Skip trivial fixes (a single typo, one dead link) unless they were part of a larger sweep.
   - If the fix required a judgment call (e.g., splitting a section, renaming a doc), record the decision in [`../../../.agents/logs/decisions.md`](../../../.agents/logs/decisions.md).

## Checks

- `scripts/verify-harness.sh` exits with zero errors (no broken links, no length violations).
- Every relative link in edited files has been confirmed to point to an existing path (`ls` or `find` evidence — not assumed).
- `AGENTS.md` line count ≤ 200; `CLAUDE.md` line count ≤ 250.
- No content was silently deleted — moved detail is reachable via a link from its former location.
- Changelog entry recorded for non-trivial changes.
- No secrets, no AI/LLM attribution introduced into any doc.

## Common Failure Modes

- **Fixing the link path without checking the target exists** — a corrected path that still 404s is still broken. Always confirm with `ls`.
- **Shrinking entry files by deleting instead of moving** — content that disappears without a forwarding link creates hidden knowledge loss. Move, then link.
- **Drifting cross-references** — correcting one file without checking files that link *to* it. When a doc is renamed or moved, grep for its old path and update every inbound reference.
- **Over-editing** — treating maintenance as a chance to rewrite doctrine. Fix accuracy and links only; escalate structural rewrites to a separate authoring task.
- **Skipping the re-run** — declaring done after the first fix pass without re-running `verify-harness.sh`. Fixes can introduce new issues.

## Example Usage

> `/docs-loop` surfaces two broken links in `.agents/context/skills.md` pointing to deleted skill files, and `CLAUDE.md` at 261 lines. This skill runs: broken links removed and prose updated (step 2), a "Model Tiering" section (18 lines) extracted into `.agents/context/model-tiering.md` with a one-line summary + link replacing it in `CLAUDE.md` (step 3), `verify-harness.sh` re-run → clean (step 4), changelog entry written (step 5).

## Related Commands

`/docs-loop`, `/refresh-context`

See also [`../../../.agents/workflows/workflow-improvement.md`](../../../.agents/workflows/workflow-improvement.md) for the broader process of identifying and improving harness documentation gaps.

## Maintenance Notes

- If `scripts/verify-harness.sh` gains new checks (e.g., frontmatter validation, cross-reference depth), update the Procedure and Checks sections accordingly.
- If the entry-file length limits change, update step 3 and the Checks section with the new values.
- Keep the link-prefix rules in step 2 in sync with the canonical prefixes documented in [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md).
- This skill pairs with [`../context-mapping/SKILL.md`](../context-mapping/SKILL.md) — context-mapping creates/refreshes the map structure; this skill keeps it accurate over time.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
