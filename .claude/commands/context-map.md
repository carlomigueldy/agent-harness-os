---
description: Generate a recursive AGENTS.md context map for a directory
argument-hint: "[directory]"
---

# /context-map

> Inspect a directory, decide if a local `AGENTS.md` is warranted, and write one from the context file schema so future agents can work there safely.

## Purpose

Use this when a directory has non-obvious rules, conventions, ownership boundaries, or risks that a fresh agent would otherwise have to reverse-engineer. Produces a local `AGENTS.md` anchored to the context file schema, cross-linked to relevant harness workflows, skills, and commands.

Directory: **$ARGUMENTS**

## Usage

`/context-map <directory>` — e.g. `/context-map src/payments` or `/context-map .agents/workflows`.

Omit the argument to map the current working directory.

## Preconditions

- Root [`AGENTS.md`](../../AGENTS.md) has been read and the session is oriented to the repo.
- The target directory exists and is tracked by git.
- Context-mapping doctrine read: [`.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md).

## Procedure

Inspect the directory, apply warrant criteria, write `<dir>/AGENTS.md` from the schema, cross-link workflows/skills/commands, run `verify-harness.sh`, register in the context index. Full procedure: [`context-mapping`](../../.claude/skills/context-mapping/SKILL.md) + [`.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md).

## Stop Conditions

Success: file written, passes verifier, added to index. Skip (no write): directory doesn't meet warrant criteria — state reason. Escalate: purpose ambiguous or directory contains production-sensitive content.

## Safety

If `<dir>/AGENTS.md` already exists, read it first and preserve accurate content. Do not commit without review. Never echo secret values found during inspection.

## Output

Emits a Context Map report (warranted: yes/no, file written, links verified, verify-harness.sh result, context index updated). Full procedure, warrant criteria, schema, and required sections: [`.agents/workflows/context-mapping.md`](../../.agents/workflows/context-mapping.md). Skill: [`context-mapping`](../../.claude/skills/context-mapping/SKILL.md).

## Related

- **Skills:** [`context-mapping`](../../.claude/skills/context-mapping/SKILL.md)
- **Workflows:** [`context-mapping.md`](../../.agents/workflows/context-mapping.md)
- **Commands:** `/refresh-context`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
