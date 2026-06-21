# Subagents

Reusable, model-tiered subagent role definitions live in [`../../.claude/agents/`](../../.claude/agents/), one `.md` per role. Claude Code provisions them into any repo that adopts this template, and the [dynamic workflows](../workflows/dynamic-workflows.md) and [agent teams](../workflows/agent-teams.md) delegate to them to run work in parallel.

This file is the **index and authoring contract** for those subagents. For invokable commands see [`slash-commands.md`](slash-commands.md); for skills see [`skills.md`](skills.md).

> **Namespace rule:** like `.claude/commands/`, every `.md` under `.claude/agents/` is parsed as an agent definition — never put an `AGENTS.md`/`README.md` there (it would register as an `/agents/AGENTS` agent). This index lives here in `.agents/context/` instead. `verify-harness.sh` enforces it.

> **Other runtimes:** In Claude Code, subagent roles live in `.claude/agents/`. Other runtimes assign roles manually using the specs in this file. See [`runtimes.md`](runtimes.md) for the full concept mapping.

---

## Why reusable subagents

- **Role specialization** — each agent has one clear responsibility and a system prompt tuned for it.
- **Model tiering** — each role is pinned to the cheapest tier that does the job well (haiku → sonnet → opus), so a fleet doesn't burn opus on mechanical work.
- **Parallelism** — a workflow script fans work out to several subagents at once; they return structured results to an orchestrator that synthesizes.
- **Self-evolution** — `skill-smith` safely turns repeated work into new skills/commands, gated by approval.

## Subagent File Schema

Every file in `.claude/agents/<name>.md` follows this shape. `verify-harness.sh` checks the frontmatter and required headings.

````md
---
name: <name == filename, lower-kebab-case>
description: <when the orchestrator should delegate to this subagent — used for auto-routing>
tools: <OMIT to inherit all; for a read-only agent list ONLY read tools, e.g. "Read, Grep, Glob" — never Bash/Edit/Write, which grant execution/writes>
model: <haiku | sonnet | opus>   # REQUIRED — the model tier for this role
---

# <Title> (<model> tier)

## Role
## When to Use
## Operating Rules
## Harness Skills & Commands
## Output
````

**Required frontmatter:** `name`, `description`, `model` (one of `haiku`/`sonnet`/`opus`). **Required headings:** `## Role`, `## When to Use`, `## Operating Rules`, `## Harness Skills & Commands`, `## Output`.

## Model Tiering

| Tier | Use for | Roles |
|---|---|---|
| **opus** | Architecture, review, safety, synthesis, self-evolution | `planner`, `architect`, `reviewer`, `safety-reviewer`, `integrator`, `skill-smith` |
| **sonnet** | Implementation, tests, debugging, docs | `implementer`, `tester`, `debugger`, `docs-writer` |
| **haiku** | Read-only discovery and search | `scout` |

## Roster

| Subagent | Tier | Role | Leans on |
|---|---|---|---|
| [`planner`](../../.claude/agents/planner.md) | opus | Decompose a goal into a sprint contract, acceptance criteria, and the lightest orchestration mode | `/gated-orchestration`, `github-issue-planning` |
| [`architect`](../../.claude/agents/architect.md) | opus | Architecture/system-design decisions, ADRs, structural review | `/architecture-review`, `context-mapping` |
| [`reviewer`](../../.claude/agents/reviewer.md) | opus | Strict 10/10 review gate with categorized findings | `/review-10x`, `opus-code-review` |
| [`safety-reviewer`](../../.claude/agents/safety-reviewer.md) | opus | Secrets, authz, injection, unsafe/runaway automation | `/security-review`, `security-review` skill |
| [`integrator`](../../.claude/agents/integrator.md) | opus | Merge parallel outputs, final verification, handoff | `/release-check`, `/final-handoff` |
| [`skill-smith`](../../.claude/agents/skill-smith.md) | opus | Safe self-evolution: author skills/commands (approval-gated) | `/create-skill`, `/create-command`, `skill-authoring` |
| [`implementer`](../../.claude/agents/implementer.md) | sonnet | Scoped implementation; verifies its own work | `/build-loop`, `/test-loop` |
| [`tester`](../../.claude/agents/tester.md) | sonnet | Tests + evidence; never weakens a test | `/test-loop`, `test-debugging` |
| [`debugger`](../../.claude/agents/debugger.md) | sonnet | Root-cause failing tests/CI; isolate → hypothesize → verify | `/fix-loop`, `/ci-debug` |
| [`docs-writer`](../../.claude/agents/docs-writer.md) | sonnet | Docs, context maps, handovers within length limits | `/docs-loop`, `/context-map`, `/refresh-context` |
| [`scout`](../../.claude/agents/scout.md) | haiku | Read-only inventory/search; compact findings | `repo-discovery` |

## Using subagents in dynamic workflows

A workflow script assigns each task to a role via `agentType`, runs them in parallel, and feeds the results to an orchestrator. A canonical pipeline:

```text
scout (discover)  →  planner (decompose)  →  implementer ∥ tester (build+cover)
                  →  reviewer ∥ safety-reviewer (gate)  →  integrator (synthesize + handoff)
```

See [`../workflows/dynamic-workflows.md`](../workflows/dynamic-workflows.md) for the orchestration patterns and [`../workflows/agent-teams.md`](../workflows/agent-teams.md) for collaborative (non-scripted) use. Respect the cost limits in [`../workflows/orchestration.md`](../workflows/orchestration.md) — don't fan out wider than the work warrants.

## Adding a subagent

1. Run `/create-command`-style authoring or copy an existing role file.
2. Set `name` (== filename), a routing-focused `description`, and the right `model` tier.
3. Fill the required headings; link skills with `../../.claude/skills/<name>/SKILL.md` and reference commands as code spans.
4. Add a row to the Roster above and run `bash scripts/verify-harness.sh`.

The [`skill-smith`](../../.claude/agents/skill-smith.md) subagent can do this for you under the approval gate.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
