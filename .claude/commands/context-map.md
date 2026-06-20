---
description: Generate a recursive AGENTS.md context map for a directory
argument-hint: "[directory]"
---

# /context-map

> Inspect a directory, decide if a local `AGENTS.md` is warranted, and write one from the context file schema so future agents can work there safely.

## Purpose

Use this when a directory has non-obvious rules, conventions, ownership boundaries, or risks that a fresh agent would otherwise have to reverse-engineer. It produces a local `AGENTS.md` anchored to the context file schema, cross-linked to the relevant harness workflows, skills, and commands.

Directory: **$ARGUMENTS**

## Usage

`/context-map <directory>` — e.g. `/context-map src/payments` or `/context-map .agents/workflows`.

Omit the argument to map the current working directory.

## Parameters

- `$ARGUMENTS` (optional) — relative or absolute path to the target directory. Defaults to the current working directory if omitted.

## Preconditions

- Root [`AGENTS.md`](../../AGENTS.md) has been read and the session is oriented to the repo.
- The target directory exists and is tracked by git.
- The context-mapping doctrine in [`../../.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md) has been read.

## Procedure

1. **Inspect the directory.** Run `git ls-files <dir>` to enumerate tracked files. Read the key files (entry points, config, existing `AGENTS.md`, schema or index files) that reveal the directory's purpose, conventions, and risk zones. Note what a fresh agent would not know from the filename alone.

2. **Decide if a local `AGENTS.md` is warranted.** Apply these criteria from [`../../.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md):
   - The directory has non-obvious rules (e.g. "every `.md` here registers as a command").
   - It has its own conventions, ownership boundaries, or "do not touch without review" zones.
   - A fresh agent would otherwise have to reverse-engineer how to work here safely.

   If none of these apply, stop — state which criterion was not met and why a local context file would not add value. Do not write the file.

3. **Write `<dir>/AGENTS.md` from the context file schema.** Include these sections (thin files may collapse minor ones, but always include Purpose, Agent Rules, and Update Rules):
   - `# Context: <directory>` — heading with the exact directory path
   - `## Purpose` — what this directory is for and who owns it
   - `## Important Files` — table: path, what it is
   - `## How This Directory Is Used` — the normal flow of working here
   - `## Agent Rules` — hard rules for editing safely; what must not change without review
   - `## Common Workflows` — recurring tasks and the commands/skills that drive them
   - `## Commands` — relevant slash commands (code spans, not links)
   - `## Skills` — relevant skills with links into `.claude/skills/`
   - `## Testing / Validation` — how to verify changes (typically `bash scripts/verify-harness.sh` from repo root)
   - `## Known Risks` — footguns specific to this directory
   - `## Recent Decisions` — pointers into [`../../.agents/logs/decisions.md`](../../.agents/logs/decisions.md)
   - `## Update Rules` — when and how to update this file when the directory changes

4. **Cross-link to relevant workflows, commands, and skills.** Compute correct relative paths from `<dir>/AGENTS.md` back to the harness root. Reference the context-mapping workflow, the `/context-map` and `/refresh-context` commands, and any domain-specific workflows or skills that apply to this directory. Every link must resolve.

5. **Run `bash scripts/verify-harness.sh` from the repo root.** Confirm the new file passes link and structure checks. Then add the file path to the "Current local context files" list in [`../../.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md) so it is tracked and audited by `/refresh-context` in future sessions.

## Stop Conditions

- **Success:** `<dir>/AGENTS.md` written, passes `verify-harness.sh`, all links resolve, file added to the context index.
- **Skip:** the directory does not meet the warrant criteria — state the reason and stop without writing.
- **Escalate / stop and ask:** the directory's purpose is ambiguous after reading its files; or the directory contains sensitive/production-infrastructure content where making assumptions is too risky.

## Safety

- If `<dir>/AGENTS.md` already exists, read it first and preserve accurate content. Document what you changed and why.
- Do not commit the file unless explicitly asked — write it and let the session owner review the diff.
- No AI/LLM attribution in the new file, its commit, or any PR description.
- Never echo secret values found in config or env files while inspecting directory contents.

## Output

Emit a context-map report:

```md
## Context Map — <directory>

- Warranted: yes | no — <reason>
- File written: <path>
- Sections included: <list>
- Links verified: yes | partial — <broken links if any>
- verify-harness.sh: PASS | FAIL — <relevant output>
- Context index updated: yes | no
```

## Related

- **Skills:** [`context-mapping`](../../.claude/skills/context-mapping/SKILL.md)
- **Workflows:** [`context-mapping.md`](../../.agents/workflows/context-mapping.md)
- **Commands:** `/refresh-context`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
