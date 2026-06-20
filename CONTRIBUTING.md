# Contributing

This repository is an **agent-native harness template**. Contributions come from both humans and coding agents, and both follow the same operating system. This file is the short on-ramp; the detail lives in the harness itself.

## Start here

1. Read [`AGENTS.md`](AGENTS.md) (overview, hard constraints, definition of done) → [`CLAUDE.md`](CLAUDE.md) (Claude Code workflow).
2. Read the current state: [`claude-progress.md`](claude-progress.md) and [`session-handoff.md`](session-handoff.md).
3. Navigate with the harness index: [`.agents/README.md`](.agents/README.md).

## The non-negotiables

- **No AI/LLM attribution** anywhere — commits, PRs, code, docs, changelogs. Human-owned.
- **Never commit secrets.** `.gitignore` guards env/key files; CI scans for leaks.
- **Verification-first.** Don't claim done without evidence; if a check can't run, document why.
- **Right-sized orchestration.** Single agent by default; escalate only when the work warrants it. Don't force parallelism.
- **Strict review.** Non-trivial work passes a 10/10 review gate ([`evaluator-rubric.md`](evaluator-rubric.md)).

## How to make a change

1. **Branch** from `main`: `feat/…`, `fix/…`, `docs/…`, `chore/…`, `refactor/…`, `test/…`, or `harness/…`. Use a worktree for meaningful work — see [`.agents/workflows/worktree-sessions.md`](.agents/workflows/worktree-sessions.md).
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
