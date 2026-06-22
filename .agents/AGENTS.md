# Context: `.agents/`

> This is the agent-facing rules card for the harness core. The human-facing navigation hub is [`README.md`](README.md) — read it first for the full map and reading order.

## Purpose

`.agents/` is the harness's knowledge base and running record — the **doctrine** (`context/`, `workflows/`) and the **state** (`logs/`, `proposals/`, `artifacts/`). The invokable surfaces (`.claude/commands/`, `.claude/skills/`) point back into here; this is where the detail lives.

## Important Files

| Path | What it is |
|---|---|
| [`README.md`](README.md) | Navigation hub + reading order (start here) |
| [`context/`](context/) | Project knowledge (architecture, conventions, commands, skills, slash-commands, …) |
| [`workflows/`](workflows/) | How to do work (orchestration, review, autonomous-loops, context-mapping, …) |
| [`logs/`](logs/) | Append-only running record (decisions, changelog, progress, verification, …) |
| [`proposals/`](proposals/) | Improvement proposals (require approval) |
| [`artifacts/`](artifacts/) | Demo/verification evidence |

## How This Directory Is Used

Agents read `context/` to understand the project and `workflows/` to perform an activity, and they append to `logs/` as work happens. Commands and skills are thin entry points that drive these workflows.

## Agent Rules

- `context/` and `workflows/` are doctrine — change them deliberately; major workflow changes need a proposal in [`proposals/`](proposals/) (see [`workflows/workflow-improvement.md`](workflows/workflow-improvement.md)).
- `logs/` is append-only running state — see [logs/ rules in README.md](README.md#logs-rules).
- Do not duplicate content across `context/`/`workflows/` and the root entry files — link instead. The harness's rule is "merge & improve, don't duplicate".
- Keep cross-links accurate; `verify-harness.sh` fails on broken relative links.
- No AI/LLM attribution in any file here.

## Common Workflows

- **Find your way:** [`README.md`](README.md) → the relevant `workflows/` file.
- **Add doctrine:** propose via [`workflows/workflow-improvement.md`](workflows/workflow-improvement.md); on approval, add the doc and link it from [`README.md`](README.md).
- **Record state:** append to the right log in [`logs/`](logs/).

## Commands

`/context-map`, `/refresh-context`, `/gated-orchestration`. See [`context/slash-commands.md`](context/slash-commands.md).

## Skills

[`context-mapping`](../.claude/skills/context-mapping/SKILL.md), [`documentation-maintenance`](../.claude/skills/documentation-maintenance/SKILL.md).

## Testing / Validation

`bash ../scripts/verify-harness.sh` checks structure, link resolution, and that each subsystem dir holds enough docs.

## Known Risks

- Letting `context/`/`workflows/` drift from the actual repo (stale file maps). Refresh with `/refresh-context`.
- Bloating the root entry files instead of splitting detail into here.

## Recent Decisions

- 2026-06-20 — Reconcile new surfaces onto `.agents/`; no parallel `docs/` tree. See [`logs/decisions.md`](logs/decisions.md).

## Update Rules

When you add/move/remove a doc here, update [`README.md`](README.md)'s tables and re-run `verify-harness.sh`. Note meaningful changes in [`logs/changelog.md`](logs/changelog.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](README.md) and [AGENTS.md](../AGENTS.md)._
