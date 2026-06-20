# Context: `.claude/skills/`

## Purpose

Project skills — reusable, on-demand procedures Claude Code loads when a task matches their `description`. Each skill is one directory holding a `SKILL.md`. These encode the harness's recurring agent workflows (review, discovery, authoring, handoffs, etc.) so agents don't reinvent them.

## Important Files

| Path | What it is |
|---|---|
| `<name>/SKILL.md` | A single skill. `name` frontmatter must equal `<name>` (the directory). |
| `../README.md` | Overview of the whole `.claude/` surface |
| `../../.agents/context/skills.md` | Skill schema + full project-skill index (the canonical contract) |

## How This Directory Is Used

Claude Code reads each `SKILL.md`'s frontmatter `description` and offers the skill when relevant. The body is loaded into context on use. Skills are *procedures*, not invocations — a slash command in `../commands/` typically drives a skill.

## Agent Rules

- One skill per directory; `name` (frontmatter) **must** equal the directory name, lower-kebab-case.
- Follow the skill schema in [`../../.agents/context/skills.md`](../../.agents/context/skills.md). Required headings and frontmatter are checked by `verify-harness.sh`.
- Keep skills procedure-first and stack-agnostic (this is a template). Use `{{PLACEHOLDER}}` for project-specific values.
- Every skill links back to at least one related command. No AI/LLM attribution; never echo secrets.

## Common Workflows

- **Add a skill:** run `/create-skill <name>` (drives [`skill-authoring`](skill-authoring/SKILL.md)), then add it to the index in `../../.agents/context/skills.md`.
- **Audit skills:** `/skill-evolution-loop` scans recent work for repeated patterns worth turning into skills.

## Commands

`/create-skill`, `/skill-evolution-loop`. See [`../../.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md).

## Skills

This directory *is* the skills. The authoring procedure is [`skill-authoring`](skill-authoring/SKILL.md).

## Testing / Validation

`bash ../../scripts/verify-harness.sh` validates every `SKILL.md` (frontmatter `name`/`description`, `name` == directory, required headings).

## Known Risks

- A `SKILL.md` whose `name` ≠ directory will fail verification.
- Over-broad `description` lines cause skills to trigger when they shouldn't — keep them specific.

## Recent Decisions

- 2026-06-20 — Project skills are a tracked harness surface under `.claude/skills/`; see [`../../.agents/logs/decisions.md`](../../.agents/logs/decisions.md).

## Update Rules

When you add, rename, or remove a skill: update [`../../.agents/context/skills.md`](../../.agents/context/skills.md), re-run `verify-harness.sh`, and note it in [`../../.agents/logs/changelog.md`](../../.agents/logs/changelog.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
