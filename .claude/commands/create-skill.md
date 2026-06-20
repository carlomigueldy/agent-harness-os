---
description: Scaffold a new project skill from the skill schema
argument-hint: "[skill-name]"
---

# /create-skill

> Create a new, schema-conformant project skill under `.claude/skills/<name>/SKILL.md` and register it in the index.

## Purpose

Use this when you want to encode a recurring agent workflow as a reusable, discoverable skill. It walks you through reading the skill schema, scaffolding a conformant `SKILL.md`, registering the skill in the project index, and verifying compliance — so the harness can discover and invoke the skill reliably.

Skill name: **$ARGUMENTS**

## Usage

`/create-skill <skill-name>` — e.g. `/create-skill feature-flag-cleanup`.

The skill name must be lower-kebab-case and will become both the directory name and the `name` frontmatter field.

## Parameters

- `$ARGUMENTS` (required) — the lower-kebab-case skill name. If empty, ask for it before proceeding.

## Preconditions

- You are working on a feature branch or worktree, not the default branch.
- The `.claude/skills/` directory exists.
- The skill name does not already exist as a directory under `.claude/skills/`.
- You have read [`../../.agents/context/skills.md`](../../.agents/context/skills.md) to understand the project skill index and the schema contract.

## Procedure

1. **Read the schema and exemplar.** Read [`../../.agents/context/skills.md`](../../.agents/context/skills.md) in full — absorb the Skill File Schema (required frontmatter, required headings, field constraints). Then read at least one existing skill (e.g. [`../../.claude/skills/opus-code-review/SKILL.md`](../../.claude/skills/opus-code-review/SKILL.md)) to calibrate tone, depth, and formatting. Note: `name` in frontmatter MUST equal the directory name, and both must equal `$ARGUMENTS`.

2. **Draft the skill content.** Before writing any file, write a brief outline:
   - **Purpose** — one paragraph, what the skill does.
   - **When to Use** — 2–5 concrete trigger conditions.
   - **When Not to Use** — 2–4 anti-triggers (what to reach for instead).
   - **Inputs** — what the agent needs before running the skill.
   - **Outputs** — what the skill produces.
   - **Procedure** — numbered, repeatable, imperative steps.
   - **Checks** — verifications to run before declaring the skill's work done.
   - **Common Failure Modes** — what goes wrong and how to avoid it.
   - **Example Usage** — a short, concrete worked example.
   - **Related Commands** — code spans for commands that invoke or compose with this skill.
   - **Maintenance Notes** — what to update when the repo changes.

3. **Create `.claude/skills/$ARGUMENTS/SKILL.md`.** Write the file with the exact schema:
   - Frontmatter: `name: $ARGUMENTS` and `description: <one line — when to use this skill>`.
   - Title line: `# Skill: $ARGUMENTS`.
   - All required headings in order: `## Purpose`, `## When to Use`, `## When Not to Use`, `## Inputs`, `## Outputs`, `## Procedure`, `## Checks`, `## Common Failure Modes`, `## Example Usage`, `## Related Commands`, `## Maintenance Notes`.
   - Write the body as imperative instructions to the agent, not third-person prose.
   - Use `{{PLACEHOLDER}}` for any project-specific values that cannot be known at authoring time.
   - End with the standard footer that every shipped skill carries — the `_Part of the {{PROJECT_NAME}} Agent Harness OS …_` line, linking the harness index (`../../../.agents/README.md`) and AGENTS.md (`../../../AGENTS.md`) as markdown links from inside the skill dir.
   - Never include AI/LLM attribution. Never echo secret values.

4. **Register the skill in the project index.** Open [`../../.agents/context/skills.md`](../../.agents/context/skills.md) and add a row for `$ARGUMENTS` to the **Project Skill Index** table. The index sits at depth two, so the skill link uses the `../../.claude/` prefix:
   ```
   | `$ARGUMENTS` — link as `../../.claude/skills/$ARGUMENTS/SKILL.md` | <one-line purpose matching the description field> |
   ```
   Keep the table sorted or append at the end — do not disrupt existing rows.

5. **Run the harness verifier.** Execute `bash scripts/verify-harness.sh` from the repo root. Confirm the script reports the new skill as conformant — no missing frontmatter fields, no missing required headings. If it reports errors, fix them and re-run until clean.

6. **Self-review.** Re-read the file you wrote and confirm:
   - Frontmatter is present and `name` equals the directory name.
   - All required headings are present in the correct order.
   - Links to files outside the skills tree use the `../../../` prefix (from inside `.claude/skills/$ARGUMENTS/`); links to a sibling skill use `../<other-skill>/SKILL.md`.
   - The `description` field is a single line that serves as a discovery trigger — a future agent reading it should know when to load this skill.
   - No filler, no vague prose — every section is actionable.

## Stop Conditions

- **Success:** `SKILL.md` is written and passes `verify-harness.sh`; the project skill index row is added; self-review confirms no schema violations.
- **Stop and ask:** the skill name collides with an existing directory; the purpose is too vague to write a meaningful `When to Use` section (ask for clarification); `verify-harness.sh` fails after two fix-and-retry cycles (document the error and stop).
- Never write the file if the skill name is empty or not lower-kebab-case — prompt for the correct name first.

## Safety

- Confirm before overwriting an existing `SKILL.md` — do not silently replace an existing skill.
- Never include AI/LLM attribution (no "Generated by", "Claude", co-author tags) in the skill file or any commit message.
- Never echo or store secret values inside the skill body.
- Keep skill content stack-agnostic unless the skill is explicitly scoped to a known stack — use `{{PLACEHOLDER}}` for project-specific values.

## Output

Emit a compact scaffold report after completing all steps:

```md
## Skill Scaffolded — $ARGUMENTS

- File: .claude/skills/$ARGUMENTS/SKILL.md
- Index: .agents/context/skills.md updated (row added)
- verify-harness.sh: <PASS / FAIL — error if any>
- Required headings: all present
- Notes: <any deviations or follow-ups>
```

## Related

- **Workflows:** [`workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md)
- **Commands:** `/create-command`, `/skill-evolution-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
