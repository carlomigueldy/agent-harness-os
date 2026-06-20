---
name: context-mapping
description: Create or refresh recursive AGENTS.md/CLAUDE.md context maps for a directory without letting them drift
---

# Skill: context-mapping

## Purpose

Decide whether a directory warrants its own local context file, then write or refresh a `<dir>/AGENTS.md` from the context file schema so a fresh agent can work there safely without reverse-engineering its rules. This is the doctrine behind the `/context-map` and `/refresh-context` commands; the full workflow lives in [`../../../.agents/workflows/context-mapping.md`](../../../.agents/workflows/context-mapping.md). For keeping the prose within those files accurate and within length limits, pair with [`../documentation-maintenance/SKILL.md`](../documentation-maintenance/SKILL.md).

## When to Use

- A directory has non-obvious rules, conventions, ownership boundaries, or "do not touch without review" zones a fresh agent would otherwise miss.
- Files were added, moved, or deleted in a directory that already has a context file — audit it for drift.
- You are creating a new local `AGENTS.md`/`CLAUDE.md` for a directory (`/context-map`).
- You are auditing existing context files for freshness against the real tree (`/refresh-context`).

## When Not to Use

- The directory is self-explanatory from its filenames and a fresh agent needs no extra rules — adding a context file is noise, not signal.
- The directory is `.claude/commands/` — every `.md` file there registers as a slash command, so a context file would become an unintended command. Document it in [`../../../.agents/context/slash-commands.md`](../../../.agents/context/slash-commands.md) instead.
- The change is a one-off edit that does not alter how the directory is worked in — update the affected lines in the existing file rather than a full remap.
- The directory's purpose is genuinely ambiguous or it holds sensitive/production-infra content where assumptions are risky — stop and ask rather than guess.

## Inputs

- The target directory path and read access to its tracked files (`git ls-files <dir>`).
- The root [`../../../AGENTS.md`](../../../AGENTS.md) and the context-mapping workflow doctrine in [`../../../.agents/workflows/context-mapping.md`](../../../.agents/workflows/context-mapping.md).
- Any existing `<dir>/AGENTS.md` to preserve accurate content during a refresh.

## Outputs

- A `<dir>/AGENTS.md` written from the context file schema (Purpose, Important Files, Agent Rules, Update Rules at minimum), with every relative link resolving back to the harness root.
- The file recorded in the context index inside the context-mapping workflow so `/refresh-context` audits it on the next pass.

## Procedure

1. **Inspect the directory contents.** Run `git ls-files <dir>` to enumerate tracked files. Read the entry points, config files, schema/index files, and any existing context file. Note what a filename alone does not reveal about rules, risks, or conventions.

2. **Decide whether a local `AGENTS.md` is warranted; if not, stop.** Apply the criteria from [`../../../.agents/workflows/context-mapping.md`](../../../.agents/workflows/context-mapping.md): non-obvious rules, own conventions/ownership, or reverse-engineering risk. If none of those apply, explicitly state which criterion failed and do not write the file.

3. **Write or update from the context file schema with an accurate file map and rules.** Produce `<dir>/AGENTS.md` with the `# Context: <directory>` heading and the schema sections (Purpose, Important Files, How This Directory Is Used, Agent Rules, Common Workflows, Testing / Validation, Known Risks, Update Rules). Thin directories may collapse minor sections but always keep Purpose, Agent Rules, and Update Rules.

4. **Cross-link with correct relative paths; verify links resolve.** Compute relative paths from `<dir>/AGENTS.md` to the harness root (count directory segments carefully). Reference relevant workflows, skills, and commands. Run `bash scripts/verify-harness.sh` from the repo root to confirm every link resolves. Reference slash commands as code spans (`/context-map`, `/refresh-context`), never as markdown links.

5. **Keep it updated in the same change that alters the directory.** When files are added, moved, or deleted in the directory, update the context file in the same commit — never as a follow-up. Add the new or modified file to the context index so future `/refresh-context` runs catch drift.

## Checks

- `bash scripts/verify-harness.sh` passes — structure and every relative link resolve.
- Required sections present; the heading carries the exact directory path (`# Context: <dir>`).
- No secret values echoed from inspected config or env files; no AI/LLM attribution in the written file.
- The file is recorded in the context index so future `/refresh-context` runs catch drift.
- `.claude/commands/` is not given a local context file (every `.md` there becomes a command).

## Common Failure Modes

- **Mapping a directory that does not warrant it** — producing a context file that is noise. Honor the warrant criteria and skip with a stated reason.
- **Broken back-links** — miscomputing the relative depth from `<dir>` to root. Count directory segments explicitly and verify each path resolves before committing.
- **Drift** — writing the file once and never re-auditing. Record it in the context index and re-run `/refresh-context` whenever the directory changes.
- **Leaking secrets** — surfacing values from `.env` or config files while documenting the directory. Reference keys by name only, never by value.
- **Over-writing `.claude/commands/`** — placing an `AGENTS.md` there registers it as a slash command. Document that directory in the slash-commands context doc instead.

## Example Usage

> `/context-map src/payments`: inspect the directory, confirm it has non-obvious authz rules and money-handling conventions (warranted), write `src/payments/AGENTS.md` with Agent Rules and Known Risks sections, verify all relative links resolve with `verify-harness.sh`, and record the file in the context index. Later, when a new payment provider module lands, `/refresh-context src/payments` re-checks it against the real tree and updates the Important Files table in the same PR.

## Related Commands

`/context-map`, `/refresh-context`

## Maintenance Notes

Keep this skill in step with [`../../../.agents/workflows/context-mapping.md`](../../../.agents/workflows/context-mapping.md) and the context file schema. When the schema's required sections change, update step 3 and the Checks list accordingly. For general prose-quality and length-limit concerns in the written context files, apply [`../documentation-maintenance/SKILL.md`](../documentation-maintenance/SKILL.md). Record notable decisions in [`../../../.agents/logs/decisions.md`](../../../.agents/logs/decisions.md).

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
