# Contributing

This repository is an **agent-native harness template**. Contributions come from both humans and coding agents, and both follow the same operating system. This file is the short on-ramp; the detail lives in the harness itself.

## Start here

Read [`AGENTS.md`](AGENTS.md) first — it has the required reading order, hard constraints, and definition of done. Then follow [`CLAUDE.md`](CLAUDE.md) for the Claude Code workflow and [`.agents/README.md`](.agents/README.md) to navigate the harness.

## How to make a change

1. **Branch** from `main`: `feat/…`, `fix/…`, `docs/…`, `chore/…`, `refactor/…`, `test/…`, or `harness/…`. Use a worktree for meaningful work — see [`.agents/context/worktrees.md`](.agents/context/worktrees.md).
2. **Plan** with a sprint contract in [`.agents/logs/progress.md`](.agents/logs/progress.md) (or run `/gated-orchestration`).
3. **Implement** scoped changes; keep entry files within length limits (`AGENTS.md` ≤ 200, `CLAUDE.md` ≤ 250).
4. **Verify:** `bash scripts/verify-harness.sh` must pass locally — it is the single source of verification truth, and CI runs the same script.
5. **Review** non-trivial work with `/review-10x` (strict 10/10).
6. **Update state:** changelog, progress, and a handover ([`/final-handoff`](.claude/commands/final-handoff.md)).
7. **Open a PR** using the [PR template](.github/pull_request_template.md); link any issue with `Closes #N`.

## Extending the harness

This template is meant to grow. When a workflow repeats, capture it:

| To add… | Use | Then |
|---|---|---|
| A slash command | `/create-command` | add it to [`.agents/context/slash-commands.md`](.agents/context/slash-commands.md) |
| A skill | `/create-skill` | add it to [`.agents/context/skills.md`](.agents/context/skills.md) |
| A context map | `/context-map <dir>` | per [`.agents/workflows/context-mapping.md`](.agents/workflows/context-mapping.md) |
| A workflow / doctrine | proposal in [`.agents/proposals/`](.agents/proposals/) | per [`.agents/workflows/workflow-improvement.md`](.agents/workflows/workflow-improvement.md) |

`scripts/verify-harness.sh` validates command, skill, and context-map schemas — new surfaces can't silently rot.

## Adopting this template into your own project

Run the one-time [adoption workflow](.agents/workflows/adoption.md): fill the `{{PLACEHOLDER}}` values and `<!-- FILL -->` sections, then verify. After adoption, replace this file and `README.md` with your project's own — keep a pointer to `.agents/README.md` so the harness stays discoverable.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](.agents/README.md) and [AGENTS.md](AGENTS.md)._
