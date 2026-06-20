---
name: command-authoring
description: Author a schema-conformant .claude/commands/ slash command with frontmatter, required headings, and correct relative links
---

# Skill: command-authoring

## Purpose

Produce a new `.claude/commands/<name>.md` slash command that passes `verify-harness.sh` schema checks, has correct relative links, and is registered in the command index. This is the procedure behind `/create-command` and should be followed whenever a workflow needs an invokable entry point or a repeatable multi-step operation needs to be standardized. Full workflow context lives in [`../../../.agents/workflows/workflow-improvement.md`](../../../.agents/workflows/workflow-improvement.md).

## When to Use

- A workflow needs an invokable entry point (a multi-step operation agents will trigger by name).
- Standardizing a repeatable operation that currently runs as ad hoc instructions.
- The task is driven by `/create-command`.
- A skill exists (`../skill-authoring/SKILL.md`) but no command surfaces it — add the command to make discovery reliable.

## When Not to Use

- An existing command already covers the need — confirm by checking [`../../../.agents/context/slash-commands.md`](../../../.agents/context/slash-commands.md) before creating a new one.
- The operation is a one-off task with no recurring trigger — a skill or inline instruction is sufficient.
- The command name would collide with a built-in Claude Code command (`/loop`, `/help`, `/clear`, etc.) — stop and choose a distinct name.

## Inputs

- The desired command name (lower-kebab-case, no leading `/`).
- A one-line purpose statement (imperative, ≤ 100 characters) — becomes the `description` frontmatter and the index entry.
- Whether the command accepts `$ARGUMENTS` and what they are.
- Awareness of which existing commands and skills this new command composes with.

## Outputs

- `/.claude/commands/<name>.md` — a schema-valid command file with frontmatter, all required headings, imperative body, correct relative links, and the standard footer.
- An updated row in the command index table inside [`../../../.agents/context/slash-commands.md`](../../../.agents/context/slash-commands.md).
- A passing `verify-harness.sh` run confirming schema compliance and link resolution.

## Procedure

1. **Read the schema and the exemplar command.** Open [`../../../.agents/context/slash-commands.md`](../../../.agents/context/slash-commands.md) and read the full Command File Schema section: required frontmatter fields (`description`, optional `argument-hint`, optional `model`), required headings in order, naming rules, link prefixes, and the footer rule. Then open `.claude/commands/gated-orchestration.md` and calibrate style, depth, and imperative voice. Note how the Procedure steps are worded — each step is a direct instruction, not a description.

2. **Write `.claude/commands/<name>.md` with all required headings.** Apply these rules:
   - YAML frontmatter: `description` (one imperative line); `argument-hint` if the command takes arguments; `model: opus` only for review, architecture, security, or planning commands — omit otherwise.
   - `# /<name>` heading followed by a `>` purpose blockquote.
   - Required headings in exact order: `## Purpose`, `## Usage`, `## Parameters`, `## Preconditions`, `## Procedure`, `## Stop Conditions`, `## Safety`, `## Output`, `## Related`.
   - Write the body as an actionable prompt in imperative voice. Use `$ARGUMENTS`, `$1`, `$2` where the command takes input.
   - Use `{{PLACEHOLDER}}` for any project-specific values; never hardcode a stack.
   - No AI/LLM attribution anywhere in the file.
   - Relative link prefix for a file at `.claude/commands/<name>.md`: workflows → `../../.agents/workflows/<file>.md`; context docs → `../../.agents/context/<file>.md`; skills → `../../.claude/skills/<skill-name>/SKILL.md`; harness index → `../../.agents/README.md`; AGENTS.md → `../../AGENTS.md`. Reference sibling commands as code spans (`/name`), never as markdown links.
   - End with the exact footer, substituting the command file's two-levels-up root prefix `<ROOT>` = `../..`: `_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](<ROOT>/.agents/README.md) and [AGENTS.md](<ROOT>/AGENTS.md)._` (so the command file ships `../../.agents/README.md` and `../../AGENTS.md`).

3. **Write the Procedure as an imperative prompt; reference sibling commands as code spans.** Each numbered step should be a direct instruction the executing agent follows. Where the command composes with another command, write `/sibling-command` as a code span inline — never a markdown link. Cross-reference relevant skills using their relative path links.

4. **Register the command in the command index.** Open [`../../../.agents/context/slash-commands.md`](../../../.agents/context/slash-commands.md), locate the appropriate group table (Orchestration, Context maps, Authoring, Autonomous loops, Review and safety gates, Delivery — or add a new group if none fits). Insert a row: `[/<name>](../../.claude/commands/<name>.md)`, model tier if set, one-line purpose matching the `description` field exactly.

5. **Run `verify-harness.sh` to confirm schema and link resolution.** Execute `bash scripts/verify-harness.sh` from the repo root. Confirm: frontmatter and required headings are present, no stray non-command `.md` files are registered under `.claude/commands/`, and all markdown links use the correct relative prefixes. Fix any reported issues and rerun until the script passes. Do not mark done until it passes.

## Checks

- `bash scripts/verify-harness.sh` passes with no schema errors and no broken links.
- Frontmatter contains `description`; `name` is not in frontmatter (that is the skill schema, not the command schema).
- All required headings present in exact order: `## Purpose`, `## Usage`, `## Parameters`, `## Preconditions`, `## Procedure`, `## Stop Conditions`, `## Safety`, `## Output`, `## Related`.
- `model: opus` is set only for review, architecture, security, or planning commands.
- Sibling commands are referenced as code spans, not markdown links.
- No AI/LLM attribution; no secrets, API keys, or real env-var values in the file.
- The command index row was added and matches the `description` field verbatim.
- No `AGENTS.md`, `README.md`, or non-command `.md` placed inside `.claude/commands/`.

## Common Failure Modes

- **Missing or wrong-order headings** — `verify-harness.sh` fails. Follow the exact required heading order from the schema doc.
- **Broken relative links** — miscomputing the depth from `.claude/commands/<name>.md` to the repo root (two levels up: `../../`). Verify each path manually before writing.
- **Overusing `model: opus`** — setting it on commands that are neither review, architecture, security, nor planning. Reserve it; session default is sufficient for most commands.
- **Linking to sibling commands** — markdown links to sibling command files break when the repo root changes. Always use code spans (`/name`).
- **Forgetting the index** — the command file exists but is not registered. The index is the discovery surface; both must be updated together.
- **Hardcoding a stack** — writing `Next.js`, `Supabase`, or similar in the body. Use `{{PLACEHOLDER}}` for anything project-specific.

## Example Usage

> `/create-command dependency-audit`: read the schema and the exemplar, write `.claude/commands/dependency-audit.md` with `description: "Audit all dependencies for outdated versions and known CVEs"` (no `model` override), required headings, `$ARGUMENTS` wired to a target package scope, and a `## Procedure` that calls `/review-10x` as a code span. Add a row to the Delivery group in `slash-commands.md`. Run `verify-harness.sh` — passes. Report: file created, index updated, script PASS.

## Related Commands

`/create-command`, `/create-skill`

## Maintenance Notes

Keep step 1's schema reference in sync with [`../../../.agents/context/slash-commands.md`](../../../.agents/context/slash-commands.md). When required headings change in the schema, update step 2's heading list and the Checks. When `verify-harness.sh` gains new checks, update the Checks section here. See also the sibling [`../skill-authoring/SKILL.md`](../skill-authoring/SKILL.md) for the parallel procedure that authors project skills rather than commands.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
