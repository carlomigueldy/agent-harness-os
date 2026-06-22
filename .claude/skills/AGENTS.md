# Context: `.claude/skills/`

Project skills — one `<name>/SKILL.md` per skill, loaded on demand by their `description` frontmatter. The canonical schema, full project-skill index, and authoring rules live in [`../../.agents/context/skills.md`](../../.agents/context/skills.md).

## Quick reference

| Task | How |
|---|---|
| Add a skill | `/create-skill`, follow [`skill-authoring/SKILL.md`](skill-authoring/SKILL.md), register in the index |
| Validate | `bash ../../scripts/verify-harness.sh` — checks name/directory match, required headings, and links |

## Key rules

- `name` in frontmatter **must** equal the directory name (lower-kebab-case).
- Every skill links back to at least one related command and ends with the standard footer.
- Keep skills stack-agnostic; use `{{PLACEHOLDER}}` for project-specific values.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
