# Context Mapping

Recursive context maps keep agents oriented: a root entry point plus local `AGENTS.md` files in directories that warrant them, each explaining how to work safely in that area. This workflow defines what those files contain, where they belong, and how to keep them from going stale.

Drive it with `/context-map <dir>` (create) and `/refresh-context <dir>` (audit) — see [`../context/slash-commands.md`](../context/slash-commands.md) — backed by the [`context-mapping`](../../.claude/skills/context-mapping/SKILL.md) skill.

---

## The Two Context File Types

| File | Audience | Holds |
|---|---|---|
| `AGENTS.md` | All agents/humans | Purpose, file map, rules, workflows, risks for a directory |
| `CLAUDE.md` | Claude Code | Claude-specific workflow notes (only where they differ from `AGENTS.md`) |

The repo root has both. Subdirectories get an `AGENTS.md` **only where it adds real value** — do not spam every folder.

### Where a local `AGENTS.md` earns its place

- The directory has non-obvious rules (e.g. "every `.md` here registers as a command").
- It has its own conventions, ownership, or "do not touch without review" zones.
- A fresh agent would otherwise have to reverse-engineer how the directory works.

Current local context files: [`../../.claude/skills/AGENTS.md`](../../.claude/skills/AGENTS.md), `.github/AGENTS.md`, `scripts/AGENTS.md`, `../AGENTS.md` (the `.agents/` guide). The `.claude/commands/` directory is documented in [`../context/slash-commands.md`](../context/slash-commands.md), **not** an in-dir file (every `.md` there becomes a command).

---

## Context File Schema

```md
# Context: <directory>

## Purpose
What this directory is for.

## Important Files
Table of the files that matter and what they are.

## How This Directory Is Used
The normal flow of working here.

## Agent Rules
Hard rules for editing safely (what not to touch without review).

## Common Workflows
The recurring tasks and the commands/skills that drive them.

## Commands
Relevant slash commands.

## Skills
Relevant skills.

## Testing / Validation
How to verify changes here (usually `verify-harness.sh`).

## Known Risks
Footguns specific to this directory.

## Recent Decisions
Pointers into `.agents/logs/decisions.md`.

## Update Rules
When and how to update this file when the directory changes.
```

A thin file may collapse sections, but keep Purpose, Agent Rules, and Update Rules.

---

## Procedure

### Create (`/context-map <dir>`)
1. Inspect the directory's actual contents (`git ls-files <dir>`, read key files).
2. Decide whether a local `AGENTS.md` is warranted (criteria above). If not, stop and say so.
3. Write `<dir>/AGENTS.md` from the schema, with accurate file map and rules.
4. Cross-link to the relevant workflows, commands, and skills with correct relative paths.
5. Run `bash scripts/verify-harness.sh` (link + structure checks) and add the file to any index that lists context files.

### Refresh / audit (`/refresh-context <dir>`)
1. Diff what the context file claims against the real tree (added/moved/deleted files).
2. Update stale file maps, rules, and links. Remove references to files that no longer exist.
3. Confirm length limits and link resolution via `verify-harness.sh`.
4. Note non-trivial corrections in [`../logs/changelog.md`](../logs/changelog.md).

---

## Anti-Drift Rules

- Update the relevant `AGENTS.md` in the **same change** that adds, moves, or deletes files in a directory — never as a follow-up.
- `verify-harness.sh` checks that required context files exist and that their links resolve; a missing or broken context map fails CI.
- When a directory's purpose changes, rewrite its Purpose and Agent Rules first.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
