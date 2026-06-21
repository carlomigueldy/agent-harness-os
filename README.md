# Agent Harness OS — Template

[![CI](https://github.com/carlomigueldy/agent-harness-templates/actions/workflows/ci.yml/badge.svg)](https://github.com/carlomigueldy/agent-harness-templates/actions/workflows/ci.yml) [![Live demo](https://img.shields.io/badge/live%20demo-agent--harness--os.vercel.app-000?logo=vercel&logoColor=white)](https://agent-harness-os.vercel.app)

> 🔗 **Live landing page:** **<https://agent-harness-os.vercel.app>** — a single-page tour of the harness, deployed from [`landing/`](landing/) via Vercel.

A **reusable, repo-level operating system** for working with coding agents — drop it into any project so future humans, agents, subagents, agent teams, and dynamic workflows can understand, continue, verify, and hand over work without losing context.

This is **not just documentation**. It is the structure for planning, implementation, verification, review loops, retrospectives, GitHub issue tracking, demos, changelogs, multi-agent coordination, and clean handovers.

> Stack-agnostic by design. Files use `{{PLACEHOLDER}}` and `<!-- FILL -->` markers; you specialize them once during [adoption](.agents/workflows/adoption.md).

## The Five Subsystems

| Subsystem | Purpose | Key files |
|---|---|---|
| **Instructions** | Rules, constraints, definition of done | [`AGENTS.md`](AGENTS.md), [`CLAUDE.md`](CLAUDE.md), [`.agents/context/`](.agents/context/) |
| **Tools** | Commands, scripts, skills, MCP tools | [`.agents/context/commands.md`](.agents/context/commands.md), [`.agents/context/skills.md`](.agents/context/skills.md) |
| **Environment** | Runtimes, env vars, local setup | [`.agents/context/environment.md`](.agents/context/environment.md), [`init.sh`](init.sh) |
| **State** | Progress, decisions, handovers, features | [`claude-progress.md`](claude-progress.md), [`.agents/logs/`](.agents/logs/), [`feature_list.json`](feature_list.json) |
| **Feedback** | Review loops, verification, rubric | [`evaluator-rubric.md`](evaluator-rubric.md), [`.agents/logs/verification.md`](.agents/logs/verification.md) |

## Layout

```text
AGENTS.md                 # entry point for all agents (read first)
CLAUDE.md                 # Claude Code-specific workflow
init.sh                   # non-destructive session bootstrapper
feature_list.json         # machine-readable feature tracker
claude-progress.md        # current-state snapshot
session-handoff.md        # latest handover
clean-state-checklist.md  # end-of-session gate
evaluator-rubric.md       # review scoring rubric
scripts/verify-harness.sh # single source of verification truth (CI runs this)
.agents/
  README.md               # harness index / navigation hub
  context/                # project knowledge (incl. slash-commands, failure-modes)
  workflows/              # how to do work (orchestration, autonomous-loops, review, ...)
  logs/                   # running record (decisions, changelog, verification, ...)
  proposals/              # improvement proposals (require approval)
  artifacts/              # demo/verification evidence
.claude/
  README.md               # invokable surface overview
  commands/               # invokable /slash commands (thin wrappers over workflows)
  skills/                 # on-demand project skills (<name>/SKILL.md)
  agents/                 # reusable model-tiered subagents (<name>.md) for workflows
.github/                  # issue forms + PR template + CI
```

Full navigation: [`.agents/README.md`](.agents/README.md).

## Quick Start

```bash
bash init.sh            # detect stack, print branch/worktree/env status
INSTALL=1 bash init.sh  # also install dependencies
VERIFY=1 bash init.sh   # also run lint/typecheck/tests/build (when configured)
```

### Adopt it into your project

The harness ships as a template. Turn it into a live, project-specific harness with the one-time **[adoption workflow](.agents/workflows/adoption.md)**:

1. Copy the harness files into your repo root.
2. Run `bash scripts/provision.sh` to fill `{{PLACEHOLDER}}` tokens automatically — detects the stack and validates. Use `--config harness.config` for non-interactive/agent use (copy `harness.config.example`, edit, run). See the [adoption workflow](.agents/workflows/adoption.md) for the manual fallback table.
3. Fill the `<!-- FILL -->` sections, starting with [`commands.md`](.agents/context/commands.md) and [`environment.md`](.agents/context/environment.md).
4. Run `bash init.sh` (then `VERIFY=1 bash init.sh`) to validate.
5. Replace the example entries in [`feature_list.json`](feature_list.json) with real features.

Then every session begins at [`.agents/workflows/initialization.md`](.agents/workflows/initialization.md).

## How It Is Verified

The harness verifies **itself**. [`scripts/verify-harness.sh`](scripts/verify-harness.sh) is the single source of verification truth — run it locally before a PR, and CI runs the exact same script on every push and pull request to `main`:

```bash
bash scripts/verify-harness.sh
```

It checks: required structure is present, entry files stay within length limits (`AGENTS.md` ≤ 200, `CLAUDE.md` ≤ 250), `feature_list.json` is valid JSON, issue-form YAML is valid, every relative markdown link resolves, there is no AI/LLM attribution, no secrets are present, shell scripts have valid syntax, every slash command, skill, and subagent conforms to its schema, and required context maps are present.

## Core Principles

- **No AI/LLM attribution** anywhere — commits, PRs, changelogs, docs. Human-owned.
- **Never commit secrets.** `.gitignore` guards env files; CI scans for leaks.
- **Verification-first.** Don't claim done without evidence; if verification can't run, say why.
- **Demo-driven completion** for user-facing work (screenshots, GIFs, CLI output in [`.agents/artifacts/`](.agents/artifacts/)).
- **Worktree-first sessions** — isolate work in `.agents/worktrees/<branch>` (in-repo, gitignored, never outside the project dir; `--sibling` is the escape hatch); use `bash scripts/worktree.sh`; never stage copied env files.
- **GitHub-issue-driven** progress with epic/sub-issue/bug/feature forms and a PR template.
- **Epic-branch sub-issue auto-close** — `.github/workflows/epic-sync.yml` closes sub-issues when sub-PRs merge into `epic/*` branches; `scripts/sync-ledger.sh` ([`/sync-ledger`](.claude/commands/sync-ledger.md)) reconciles `feature_list.json` with live GitHub Issue state.
- **Right-sized orchestration** — single agent by default; subagents for isolated focus; agent teams for collaboration; dynamic workflows for repeatable audits/migrations. Don't force parallelism.
- **Invokable, not just documented** — workflows are exposed as real Claude Code `/commands`, skills, and reusable model-tiered [subagents](.agents/context/subagents.md) under [`.claude/`](.claude/), with bounded autonomous loops (each with a hard iteration cap). See [`.agents/context/slash-commands.md`](.agents/context/slash-commands.md).
- **Strict review loop** — a reviewer scores 1–10 and gives `PASS` / `REVISE` / `BLOCK`; autonomous loops require 10/10 with no Critical/Major issues (max 6 iterations).
- **Runtime-agnostic core** — the `.agents/` doctrine works unchanged across Claude Code, Codex, and generic runtimes; adapters are thin wrappers. See [`.agents/context/runtimes.md`](.agents/context/runtimes.md) and the [`.codex/`](.codex/) adapter.

See the [orchestration decision matrix](.agents/workflows/orchestration.md) and the [evaluator rubric](evaluator-rubric.md).

## Where to Look Next

| You want to… | Go to |
|---|---|
| Onboard as an agent | [`AGENTS.md`](AGENTS.md) → [`CLAUDE.md`](CLAUDE.md) |
| Adopt the template | [`.agents/workflows/adoption.md`](.agents/workflows/adoption.md) |
| Navigate the harness | [`.agents/README.md`](.agents/README.md) |
| Understand the design intent | [`prompt.md`](prompt.md) (harness spec, for maintainers) |

> After adoption, replace this README with your own project's README — keep a short pointer to `.agents/README.md` so the harness stays discoverable.
