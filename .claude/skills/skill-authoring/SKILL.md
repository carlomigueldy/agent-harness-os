---
name: skill-authoring
description: Author a schema-conformant .claude/skills/ project skill with frontmatter name equal to the directory and required headings
---

# Skill: skill-authoring

## Purpose

Produce a new `.claude/skills/<name>/SKILL.md` that satisfies the harness schema checked by `verify-harness.sh`, is discoverable by its frontmatter `description`, and encodes a repeatable agent procedure with enough depth to be useful without being duplicative.

## When to Use

- A recurring agent procedure has appeared more than once and is worth encoding so future sessions can invoke it consistently.
- `/create-skill` or `/skill-evolution-loop` is driving the work.
- The skill index in [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md) shows a gap that matches a known workflow.

## When Not to Use

- The procedure has appeared only once — encode it in a workflow doc or plan first; revisit after it recurs.
- A skill already exists that covers the same trigger — extend or revise the existing skill instead of duplicating it.
- The procedure is command-shaped (a single invocable action with a `## Usage` line) — use `/command-authoring` and the sibling skill [`../command-authoring/SKILL.md`](../command-authoring/SKILL.md) instead.

## Inputs

- The **skill name** in lower-kebab-case (must equal the directory that will hold it).
- A **one-line description** (the discovery trigger — what scenario makes an agent reach for this skill).
- The **procedure** to encode: the steps, checks, failure modes, and related commands that make the skill useful.
- The exemplar skill to match for style: [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md).

## Outputs

- `.claude/skills/<name>/SKILL.md` — a schema-conformant skill file.
- An updated **Project Skill Index** table in [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md).
- Confirmation that `verify-harness.sh` passes after the addition.

## Procedure

1. **Read the schema and exemplar.** Read [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md) (the "Project Skills" section for the schema) and [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) (the style exemplar). Do not skip this — the schema and style must be matched exactly.

2. **Check for duplicates.** Scan the Project Skill Index in `skills.md` and the `description` lines of existing `SKILL.md` files. If a skill already covers the same trigger, stop and extend it instead.

3. **Confirm the name.** The `name` in frontmatter and the directory name must be identical, lower-kebab-case. Decide this before creating any files.

4. **Create the directory and write `SKILL.md`.** Create `.claude/skills/<name>/SKILL.md` with:
   - Frontmatter, H1, and required headings in the order defined in the skill schema in [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md).
   - Write the body in **imperative voice** — actionable steps, not third-person description.
   - Use `{{PLACEHOLDER}}` for any project-specific values; keep the skill stack-agnostic.
   - Link workflows with prefix `../../../.agents/workflows/`, context docs with `../../../.agents/context/`, sibling skills with `../<other>/SKILL.md`. Never link to files that do not exist.
   - End with the exact footer: `_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._`
   - No AI/LLM attribution anywhere. No secrets.

5. **Register the skill** in the Project Skill Index table in [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md). Add a row: `| [\`<name>\`](../../.claude/skills/<name>/SKILL.md) | <one-line purpose> |`. Keep the table sorted or append at the end — match the existing style.

6. **Run `verify-harness.sh`** from the repo root (`bash scripts/verify-harness.sh`). Confirm section "10. Skill schema" and section "5. Markdown link resolution" both pass. Fix any failures before declaring done.

## Checks

- `verify-harness.sh` section 10 passes with no failures for the new skill.
- `verify-harness.sh` section 5 (markdown link resolution) passes — no broken links introduced.
- Frontmatter `name` exactly matches the directory name (case-sensitive).
- `description` is a single line and is specific enough to trigger discovery without being over-broad.
- All required headings are present and in the correct order.
- No AI/LLM attribution appears anywhere in the file.
- The Project Skill Index in `skills.md` includes the new entry.

## Common Failure Modes

- **`name` mismatch** — frontmatter `name` differs from the directory name (even by case). `verify-harness.sh` will fail. Always set both to the same lower-kebab-case string.
- **Over-broad description** — a trigger like "do agent work" matches everything and matches nothing. Make the description specific enough that an agent reaches for this skill only when this procedure is the right one.
- **Missing required headings** — `verify-harness.sh` checks for all six required headings. The schema lists more optional headings; include them for completeness but the six are the hard gate.
- **Broken relative links** — linking to a sibling skill or workflow that does not exist yet will fail the link-resolution check. Only link to files that are confirmed present.
- **Duplicating an existing skill** — check the index before writing. Two skills with overlapping triggers confuse discovery.
- **Stack-specific hardcoding** — writing a framework or language name instead of a `{{PLACEHOLDER}}` makes the template non-portable.

## Example Usage

> A session notices the "context-mapping" procedure is being re-derived from scratch every run. The lead agent runs `/create-skill`, picks `context-mapping` as the name, drafts the steps, runs this skill's procedure, writes `.claude/skills/context-mapping/SKILL.md`, registers it in `skills.md`, and confirms `verify-harness.sh` passes. Next session, the skill is discoverable from its description.

## Related Commands

`/create-skill`, `/skill-evolution-loop`

## Maintenance Notes

- When `verify-harness.sh` adds new required headings to the skill schema (section 10), update the Procedure and Checks sections here to match.
- When the skill index format in [`../../../.agents/context/skills.md`](../../../.agents/context/skills.md) changes, update step 5.
- Keep the link to the style exemplar [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md) current — if the exemplar is replaced, point here to the new one.
- This skill pairs with [`../../../.agents/workflows/workflow-improvement.md`](../../../.agents/workflows/workflow-improvement.md) for the broader loop of identifying, proposing, and encoding improvements to the harness.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
