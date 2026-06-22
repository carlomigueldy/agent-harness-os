# `.claude/` — Invokable Harness Surface

This directory holds the **executable** part of the {{PROJECT_NAME}} Agent Harness OS: project slash commands, project skills, and reusable subagents that Claude Code discovers and runs. The `.agents/` tree holds the *doctrine* (workflows, context, logs); `.claude/` holds the *entry points* that drive it.

> TEMPLATE NOTE: keep this directory in sync with `.agents/context/slash-commands.md` and `.agents/context/skills.md`. `scripts/verify-harness.sh` validates the schemas below on every push and PR.

## What's tracked here

| Path | What it is | Index + docs |
|---|---|---|
| [`commands/`](commands/) | Slash commands — one `.md` per command, invoked as `/<name>` | [`slash-commands.md`](../.agents/context/slash-commands.md) |
| [`skills/`](skills/) | Project skills — one `<name>/SKILL.md` per skill, loaded on demand | [`skills.md`](../.agents/context/skills.md) |
| [`skills/AGENTS.md`](skills/AGENTS.md) | Local nav guide for the skills directory | — |
| [`agents/`](agents/) | Reusable subagents — one `<name>.md` per role, model-tiered | [`subagents.md`](../.agents/context/subagents.md) |

Local/personal Claude Code state (`settings.local.json`, `worktrees/`) is git-ignored — see [`../.gitignore`](../.gitignore).

## Critical rule for `commands/` and `agents/`

Claude Code registers **every** `.md` under `commands/` as a slash command and every `.md` under `agents/` as a subagent. Never add `AGENTS.md`, `README.md`, or any non-definition file there — it would register as a stray command/agent. Those directories' documentation lives in [`../.agents/context/slash-commands.md`](../.agents/context/slash-commands.md) and [`../.agents/context/subagents.md`](../.agents/context/subagents.md) instead.

## Adding to this surface

| To add a… | Use | Authoring skill |
|---|---|---|
| Slash command | `/create-command` | [`skills/command-authoring/SKILL.md`](skills/command-authoring/SKILL.md) |
| Skill | `/create-skill` | [`skills/skill-authoring/SKILL.md`](skills/skill-authoring/SKILL.md) |
| Subagent | copy a role + edit, or `skill-smith` | [`../.agents/context/subagents.md`](../.agents/context/subagents.md) |

After adding, run `bash ../scripts/verify-harness.sh` and update the relevant index in `../.agents/context/`.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
