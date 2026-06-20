# Slash Commands

Project slash commands live in [`../../.claude/commands/`](../../.claude/commands/). Each `.md` file there is an **invokable** Claude Code command (`/<filename>`), not just documentation — its body is the prompt the agent receives when the command runs.

This file is the **index and authoring contract** for those commands. For project *skills*, see [`skills.md`](skills.md). For shell/CLI commands (install, build, test), see [`commands.md`](commands.md) — a different thing from slash commands.

> **Namespace rule (important):** Claude Code registers **every** `.md` under `.claude/commands/` as a command. Do **not** put `AGENTS.md`, `README.md`, or any non-command `.md` inside that directory — it would register as a stray `/AGENTS` / `/README` command. That is why this index lives here in `.agents/context/` and the directory holds only real command files. `verify-harness.sh` enforces this.

---

## Command File Schema

Every file in `.claude/commands/<name>.md` must follow this shape. `verify-harness.sh` checks the frontmatter and the required headings.

````md
---
description: <one imperative line shown in /help — what the command does>
argument-hint: <optional, e.g. "[pr-number]"> 
model: <optional — set to "opus" for review/architecture/security/planning commands>
---

# /<name>

> One-line restatement of purpose.

## Purpose
What this command is for and when to reach for it.

## Usage
`/<name> <args>` — concrete invocation, using `$ARGUMENTS`, `$1`, `$2` as needed.

## Parameters
Each argument, whether required, and its default.

## Preconditions
What must be true before running (clean tree, on a worktree, gh auth, etc.).

## Procedure
1. Numbered, imperative steps the agent executes. This is the real prompt body.
2. ...

## Stop Conditions
When to stop — success criteria, max iterations, and "stop and ask" triggers.

## Safety
Destructive-action guards, confirmation gates, no-secrets / no-attribution reminders.

## Output
The exact format the command should emit (report block, table, verdict, etc.).

## Related
- **Skills:** `<skill-name>` (link into `.claude/skills/`)
- **Workflows:** `.agents/workflows/<file>.md`
- **Commands:** other `/commands` this composes with
````

**Required frontmatter:** `description`. **Required headings:** `## Purpose`, `## Usage`, `## Procedure`, `## Stop Conditions`, `## Safety`, `## Output`, `## Related`.

**Authoring rules**
- File name is lower-kebab-case and becomes the command name. Keep it short and verb-led.
- The body is a *prompt*: write imperative instructions to the agent, not third-person prose.
- Review/architecture/security/planning commands set `model: opus`. Loops and mechanical commands inherit the session model.
- Every command links to at least one related skill or workflow — no orphans.
- No AI/LLM attribution anywhere. Never echo secret values.
- Use the [command-authoring](../../.claude/skills/command-authoring/SKILL.md) skill (or `/create-command`) to scaffold new ones.

---

## Command Index

Grouped by purpose. `model: opus` marks commands that run on the strongest tier.

### Orchestration & GitHub issues

| Command | Model | Purpose |
|---|---|---|
| [`/gated-orchestration`](../../.claude/commands/gated-orchestration.md) | opus | Plan → decompose → delegate → review a non-trivial task through explicit gates |
| [`/issue-plan`](../../.claude/commands/issue-plan.md) | — | Turn a goal into an epic + labeled sub-issue plan |
| [`/issue-breakdown`](../../.claude/commands/issue-breakdown.md) | — | Break an epic into scoped sub-issues with acceptance criteria |
| [`/issue-handoff`](../../.claude/commands/issue-handoff.md) | — | Write a handoff note onto an issue for the next session |

### Context maps

| Command | Model | Purpose |
|---|---|---|
| [`/context-map`](../../.claude/commands/context-map.md) | — | Generate a recursive `AGENTS.md` for a directory |
| [`/refresh-context`](../../.claude/commands/refresh-context.md) | — | Audit context files against the real tree and fix drift |

### Authoring (self-evolution)

| Command | Model | Purpose |
|---|---|---|
| [`/create-skill`](../../.claude/commands/create-skill.md) | — | Scaffold a new project skill from the skill schema |
| [`/create-command`](../../.claude/commands/create-command.md) | — | Scaffold a new slash command from the command schema |

### Autonomous loops

See [`../workflows/autonomous-loops.md`](../workflows/autonomous-loops.md) for the loop system, iteration limits, and stop conditions.

| Command | Model | Max iters | Purpose |
|---|---|---|---|
| [`/build-loop`](../../.claude/commands/build-loop.md) | — | 6 | Bounded implementation loop to a 10/10 PASS |
| [`/goal`](../../.claude/commands/goal.md) | — | 6 | Goal-driven loop: define acceptance, iterate to done |
| [`/autonomous-loop`](../../.claude/commands/autonomous-loop.md) | — | — | Meta: pick and launch the right bounded loop |
| [`/review-loop`](../../.claude/commands/review-loop.md) | opus | 10 | Reviewer scores 1–10 until 10/10 PASS |
| [`/fix-loop`](../../.claude/commands/fix-loop.md) | — | 10 | Iterate fixes until a target check passes |
| [`/test-loop`](../../.claude/commands/test-loop.md) | — | 6 | Run tests, fix failures, rerun until green |
| [`/docs-loop`](../../.claude/commands/docs-loop.md) | — | 4 | Update docs until accurate and links resolve |
| [`/issue-loop`](../../.claude/commands/issue-loop.md) | — | 6 | Work a set of issues one at a time, each via build-loop |
| [`/skill-evolution-loop`](../../.claude/commands/skill-evolution-loop.md) | — | 3 | Scan for repeated workflows; propose/create skills |

> **Naming note:** the implementation loop is `/build-loop`, not `/loop`, to avoid colliding with Claude Code's built-in `/loop` (an interval scheduler). See decision 2026-06-20.

### Review & safety gates

| Command | Model | Purpose |
|---|---|---|
| [`/review-pr`](../../.claude/commands/review-pr.md) | opus | Review a PR diff against the evaluator rubric |
| [`/review-10x`](../../.claude/commands/review-10x.md) | opus | Strict 10/10 review gate with the full review-result block |
| [`/security-review`](../../.claude/commands/security-review.md) | opus | Security review of pending changes; log findings |
| [`/architecture-review`](../../.claude/commands/architecture-review.md) | opus | Architecture-fit review against harness conventions |

### Delivery

| Command | Model | Purpose |
|---|---|---|
| [`/ci-debug`](../../.claude/commands/ci-debug.md) | — | Diagnose a failing CI run; root-cause and fix |
| [`/release-check`](../../.claude/commands/release-check.md) | — | Pre-release checklist: verify, changelog, clean state |
| [`/final-handoff`](../../.claude/commands/final-handoff.md) | — | Produce the compact end-of-session handover + clean-state check |

---

## How Commands, Skills, Workflows, and Loops Relate

- **Workflows** (`.agents/workflows/*.md`) are the *doctrine* — the durable "how we do X".
- **Skills** (`.claude/skills/*/SKILL.md`) are *reusable procedures* an agent loads on demand.
- **Commands** (`.claude/commands/*.md`) are *invokable entry points* that drive a workflow or skill on demand.
- **Loops** are commands whose procedure repeats under a bounded iteration cap with a review gate.

A command should be thin: it orchestrates and points at the workflow/skill that holds the detail, rather than duplicating it.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
