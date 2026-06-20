# `.claude/` — Invokable Harness Surface

This directory holds the **executable** part of the {{PROJECT_NAME}} Agent Harness OS: project slash commands, project skills, and reusable subagents that Claude Code discovers and runs. The `.agents/` tree holds the *doctrine* (workflows, context, logs); `.claude/` holds the *entry points* that drive it.

> TEMPLATE NOTE: keep this directory in sync with `.agents/context/slash-commands.md` and `.agents/context/skills.md`. `scripts/verify-harness.sh` validates the schemas below on every push and PR.

## What's tracked here

| Path | What it is |
|---|---|
| [`commands/`](commands/) | Project slash commands — one `.md` per command, invoked as `/<name>` |
| [`skills/`](skills/) | Project skills — one `<name>/SKILL.md` per skill, loaded on demand |
| [`skills/AGENTS.md`](skills/AGENTS.md) | Local guide for authoring and navigating skills |
| [`agents/`](agents/) | Reusable subagents — one `<name>.md` per role, model-tiered, for dynamic workflows |

Local/personal Claude Code state (`settings.local.json`, `worktrees/`) is git-ignored — see [`../.gitignore`](../.gitignore).

## Commands vs Skills vs Subagents

- **Commands** (`commands/<name>.md`) are invokable entry points. The file body **is** the prompt the agent receives. Index + schema: [`../.agents/context/slash-commands.md`](../.agents/context/slash-commands.md).
- **Skills** (`skills/<name>/SKILL.md`) are reusable procedures Claude Code loads when a task matches their `description`. Index + schema: [`../.agents/context/skills.md`](../.agents/context/skills.md).
- **Subagents** (`agents/<name>.md`) are reusable, model-tiered roles that dynamic workflows delegate to in parallel. Index + tiering: [`../.agents/context/subagents.md`](../.agents/context/subagents.md).

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
