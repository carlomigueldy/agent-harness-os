---
description: Scaffold a new slash command from the command schema
argument-hint: "[command-name]"
---

# /create-command

> Scaffold a schema-conformant slash command under `.claude/commands/<name>.md` and register it in the index.

## Purpose

Use this when you need to add a new invokable slash command to the harness. It enforces the command schema, index registration, and link hygiene so every command is consistent, discoverable, and verifiable from the start.

Command to create: **$ARGUMENTS**

## Usage

`/create-command <command-name>` — e.g. `/create-command dependency-audit`.

Omit the leading `/`; the file name is the command name.

## Parameters

- `$ARGUMENTS` (required) — the name of the command to create, in lower-kebab-case. If empty or too vague, stop and ask for a concrete name and one-line purpose before proceeding.

## Preconditions

- The repo is in a clean or feature-branch state; you are not on `main`/`master`.
- The schema doc exists at [`../../.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md).
- The exemplar command `/gated-orchestration` exists.

## Procedure

1. **Read the schema and exemplar.** Open [`../../.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md) and read the full Command File Schema section: required frontmatter fields, required headings in order, naming rules, link prefixes, and the footer rule. Then open the exemplar command `/gated-orchestration` and calibrate style, depth, and imperative voice against it. Note which headings it includes and how the Procedure steps are worded.

2. **Create the command file.** Resolve the command name from `$ARGUMENTS` (strip any leading `/`; enforce lower-kebab-case). Create `../../.claude/commands/<name>.md` with:
   - YAML frontmatter: `description` (one imperative line); `argument-hint` if the command accepts arguments; `model: opus` only if this is a review, architecture, security, or planning command — otherwise omit it.
   - `# /<name>` heading followed by a one-line `>` purpose blockquote.
   - All required headings in exact order: `## Purpose`, `## Usage`, `## Parameters`, `## Preconditions`, `## Procedure`, `## Stop Conditions`, `## Safety`, `## Output`, `## Related`.
   - Body written as an actionable prompt in imperative voice, not third-person description. Use `$ARGUMENTS`, `$1`, `$2` where the command takes input.
   - Use `{{PLACEHOLDER}}` for any project-specific values; never hardcode a stack.
   - No AI/LLM attribution anywhere in the file.
   - End with the exact footer: `_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._`
   - Every markdown link must use the correct relative prefix for a file located at `.claude/commands/<name>.md`: workflows → `../../.agents/workflows/<file>.md`; context docs → `../../.agents/context/<file>.md`; skills → `../../.claude/skills/<skill-name>/SKILL.md`; sibling commands → code span `/name`, never a link.

3. **Register in the command index.** Open [`../../.agents/context/slash-commands.md`](../../.agents/context/slash-commands.md), locate the appropriate group table (Orchestration, Context maps, Authoring, Autonomous loops, Review & safety gates, Delivery — or add a new group if none fits), and insert a row for the new command: `[/<name>](../../.claude/commands/<name>.md)`, model tier if set, one-line purpose matching the `description` field.

4. **Run verify-harness.sh.** Execute `bash scripts/verify-harness.sh` from the repo root. Confirm: schema compliance (frontmatter + required headings present), no stray non-command `.md` files registered in `.claude/commands/`, and all markdown links using the correct relative prefixes. Fix any reported issues and rerun until the script passes before marking done.

## Stop Conditions

- **Success:** `../../.claude/commands/<name>.md` exists with valid schema, the index row is added, and `verify-harness.sh` passes.
- **Stop and ask:** `$ARGUMENTS` is empty, ambiguous, or would produce a name that collides with a built-in Claude Code command (e.g. `/loop`, `/help`, `/clear`) or an existing command file.
- **Stop and fix:** `verify-harness.sh` reports a schema error or broken link — fix it before reporting done.

## Safety

- No AI/LLM attribution in the authored file, the index entry, or any commit.
- Do not embed secrets, API keys, or real env-var values — use `{{PLACEHOLDER}}`.
- Do not put `AGENTS.md`, `README.md`, or any non-command `.md` inside `.claude/commands/` — every file there registers as a slash command.
- Sibling commands are referenced as code spans (`/name`), never as markdown links — links to sibling commands break when the repo root changes.
- Do not force `model: opus` on commands that don't need it; reserve it for review, architecture, security, and planning commands.

## Output

Emit a creation report:

```md
## Command Created — /<name>
- File: .claude/commands/<name>.md
- Index group: <group name in slash-commands.md>
- Model tier: opus | (session default)
- verify-harness.sh: PASS | FAIL (<details if fail>)
- Next: invoke `/<name>` to test it, or open a PR to land it
```

## Related

- **Workflows:** [`workflow-improvement.md`](../../.agents/workflows/workflow-improvement.md)
- **Commands:** `/create-skill`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
