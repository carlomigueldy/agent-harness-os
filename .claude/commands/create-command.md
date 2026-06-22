---
description: Scaffold a new slash command from the command schema
argument-hint: "[command-name]"
---

# /create-command

> Scaffold a schema-conformant slash command under `.claude/commands/<name>.md` and register it in the index.

## Purpose

Use this when you need to add a new invokable slash command to the harness. Enforces the command schema, index registration, and link hygiene so every command is consistent, discoverable, and verifiable from the start.

Command to create: **$ARGUMENTS**

## Usage

`/create-command <command-name>` — e.g. `/create-command dependency-audit`. Omit the leading `/`; the file name is the command name. Lower-kebab-case.

If `$ARGUMENTS` is empty or too vague, stop and ask for a concrete name and one-line purpose before proceeding.

## Preconditions

- On a feature branch or worktree; not on `main`/`master`.
- Schema doc exists at [`.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md).
- The exemplar command `/gated-orchestration` exists.

## Procedure

Read the schema and the `/gated-orchestration` exemplar, create the file with all required headings, register in the index, run `verify-harness.sh`. Full schema: [`.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md). Full procedure: [`command-authoring`](../../.claude/skills/command-authoring/SKILL.md).

## Stop Conditions

Success: file exists with valid schema, index row added, verifier passes. Stop and ask: `$ARGUMENTS` is empty/ambiguous or would collide with a built-in command. Stop and fix: verifier reports schema error or broken link.

## Safety

No AI/LLM attribution in the authored file. Do not embed secrets or real env-var values — use `{{PLACEHOLDER}}`. Do not put non-command `.md` files in `.claude/commands/` — every file there registers as a slash command.

## Output

Emits a Command Created report (file, index group, model tier, verify-harness.sh result). Full schema, required headings, naming rules, link prefixes, and registration procedure: [`.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md). Command-authoring procedure: [`command-authoring`](../../.claude/skills/command-authoring/SKILL.md). Workflow: [`.agents/workflows/workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md).

## Related

- **Skills:** [`command-authoring`](../../.claude/skills/command-authoring/SKILL.md)
- **Workflows:** [`workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md)
- **Commands:** `/create-skill`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
