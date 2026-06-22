---
description: Scaffold a new project skill from the skill schema
argument-hint: "[skill-name]"
---

# /create-skill

> Create a new, schema-conformant project skill under `.claude/skills/<name>/SKILL.md` and register it in the index.

## Purpose

Use this when you want to encode a recurring agent workflow as a reusable, discoverable skill. Walks through reading the skill schema, scaffolding a conformant `SKILL.md`, registering in the project index, and verifying compliance.

Skill name: **$ARGUMENTS**

## Usage

`/create-skill <skill-name>` — e.g. `/create-skill feature-flag-cleanup`. Lower-kebab-case; becomes both the directory name and the `name` frontmatter field.

If `$ARGUMENTS` is empty, ask before proceeding.

## Preconditions

- On a feature branch or worktree, not the default branch.
- The `.claude/skills/` directory exists.
- The skill name does not already exist as a directory under `.claude/skills/`.
- Read [`.agents/context/skills.md`](../../.agents/context/skills.md) to understand the project skill index and schema contract.

## Procedure

Read the schema and an existing skill exemplar, draft the skill content, write `SKILL.md` with all required headings, register in the index, run `verify-harness.sh`, self-review. Full procedure: [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md).

## Stop Conditions

Success: `SKILL.md` passes verifier, index row added, self-review confirms no schema violations. Stop and ask: name collides, purpose is too vague, or verifier fails after two fix cycles.

## Safety

Confirm before overwriting an existing `SKILL.md`. Never include AI/LLM attribution. Never echo or store secret values inside the skill body.

## Output

Emits a Skill Scaffolded report (file, index update, verify-harness.sh result, required headings check). Full schema, required headings, naming rules, link prefixes, and registration procedure: [`.agents/context/skills.md`](../../.agents/context/skills.md). Skill-authoring procedure: [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md). Workflow: [`.agents/workflows/workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md).

## Related

- **Skills:** [`skill-authoring`](../../.claude/skills/skill-authoring/SKILL.md)
- **Workflows:** [`workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md)
- **Commands:** `/create-command`, `/skill-evolution-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
