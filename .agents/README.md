# {{PROJECT_NAME}} — Agent Harness Index

> TEMPLATE NOTE: This is the map a fresh agent uses to navigate the harness. If you are starting a new session, read this file first, then follow the reading order below.

The harness is the repo-level operating system for planning, implementation, verification, handovers, and multi-agent coordination. It is organized into five subsystems.

---

## The Five Subsystems

| Subsystem | Purpose | Key Files |
|---|---|---|
| **Instructions** | Rules, constraints, definitions of done, reading order | `../AGENTS.md`, `../CLAUDE.md`, `context/` |
| **Tools** | Commands, scripts, MCP tools, skills, superpowers | `context/commands.md`, `context/skills.md` |
| **Environment** | Runtimes, env vars, local setup, worktrees | `context/environment.md`, `../init.sh`, `context/worktrees.md` |
| **State** | Progress, decisions, handovers, feature list, changelogs | `../claude-progress.md`, `logs/`, `../feature_list.json` |
| **Feedback** | Review loops, verification, rubric, retrospectives, failures | `../evaluator-rubric.md`, `logs/verification.md`, `logs/retrospectives.md` |

---

## Reading Order for a Fresh Session

Follow this order before doing any work:

1. [`../AGENTS.md`](../AGENTS.md) — project overview, hard constraints, definition of done
2. [`../CLAUDE.md`](../CLAUDE.md) — Claude Code-specific workflow
3. [`../claude-progress.md`](../claude-progress.md) — current state snapshot
4. [`logs/progress.md`](logs/progress.md) — detailed sprint log
5. [`../session-handoff.md`](../session-handoff.md) — last handover
6. [`../feature_list.json`](../feature_list.json) — machine-readable feature status
7. [`workflows/initialization.md`](workflows/initialization.md) — full session start checklist

---

## `context/` — Project Knowledge

Static reference files. Read when you need to understand the project.

| File | Description |
|---|---|
| [`context/repo-map.md`](context/repo-map.md) | Directory structure and entry points |
| [`context/project-brief.md`](context/project-brief.md) | What the project is, why it exists, who it serves |
| [`context/architecture.md`](context/architecture.md) | System architecture, layers, data flow |
| [`context/conventions.md`](context/conventions.md) | Code style, naming, file structure, and commit conventions |
| [`context/commands.md`](context/commands.md) | All install, dev, lint, test, build, and deploy commands |
| [`context/environment.md`](context/environment.md) | Runtime versions, env vars, local setup, Docker/devcontainer |
| [`context/worktrees.md`](context/worktrees.md) | Worktree naming, creation, env file copying, and cleanup |
| [`context/skills.md`](context/skills.md) | Available skills, superpowers, and MCP tools with usage guidance |
| [`context/glossary.md`](context/glossary.md) | Project-specific terms, acronyms, and concepts |
| [`context/known-issues.md`](context/known-issues.md) | Current bugs, limitations, and technical debt |
| [`context/troubleshooting.md`](context/troubleshooting.md) | Common failure modes and how to recover |
| [`context/resources.md`](context/resources.md) | Useful external links, docs, dashboards, and references |

<!-- FILL: Add links to any additional context files specific to your project. -->

---

## `workflows/` — How to Do Work

Step-by-step operational procedures. Follow these workflows when performing the named activity.

| File | Description |
|---|---|
| [`workflows/adoption.md`](workflows/adoption.md) | One-time: turn this template into a live project harness (fill placeholders) |
| [`workflows/initialization.md`](workflows/initialization.md) | Session start checklist: read state, select worktree, select mode |
| [`workflows/planning.md`](workflows/planning.md) | Sprint contract format, task decomposition, risk assessment |
| [`workflows/implementation.md`](workflows/implementation.md) | How to implement, verify, and hand off a scoped change |
| [`workflows/review.md`](workflows/review.md) | Harness quality audit, code review, and 10/10 reviewer loop |
| [`workflows/testing.md`](workflows/testing.md) | Test strategy, running tests, interpreting failures |
| [`workflows/debugging.md`](workflows/debugging.md) | Debugging protocol: isolate, hypothesize, verify, log |
| [`workflows/handover.md`](workflows/handover.md) | Compact handover format and protocol |
| [`workflows/retrospectives.md`](workflows/retrospectives.md) | Per-task retrospective format and learning capture |
| [`workflows/github-issues.md`](workflows/github-issues.md) | Epic/sub-issue structure, labels, PR workflow |
| [`workflows/demo-capture.md`](workflows/demo-capture.md) | How to produce screenshots, GIFs, CLI output, and browser traces |
| [`workflows/release.md`](workflows/release.md) | Release checklist, changelog, tagging, deployment |
| [`workflows/orchestration.md`](workflows/orchestration.md) | Decision matrix: single agent / subagent / agent team / dynamic workflow |
| [`workflows/agent-teams.md`](workflows/agent-teams.md) | Agent team roles, work partitioning, feedback loop |
| [`workflows/dynamic-workflows.md`](workflows/dynamic-workflows.md) | When and how to create scriptable multi-subagent workflows |
| [`workflows/worktree-sessions.md`](workflows/worktree-sessions.md) | Worktree creation, env file copying, cleanup |
| [`workflows/workflow-improvement.md`](workflows/workflow-improvement.md) | When and how to propose harness or workflow improvements |

<!-- FILL: Add links to any project-specific workflow files. -->

---

## `logs/` — Running Record

Append-only logs updated throughout the project lifetime. Every session should update relevant logs before ending.

| File | Description |
|---|---|
| [`logs/progress.md`](logs/progress.md) | Current phase, sprint contracts, blockers, next actions |
| [`logs/decisions.md`](logs/decisions.md) | Architectural, tooling, and workflow decisions with rationale |
| [`logs/changelog.md`](logs/changelog.md) | Task-by-task changelog (Added / Changed / Fixed / etc.) |
| [`logs/learnings.md`](logs/learnings.md) | Short, searchable, actionable lessons from every session |
| [`logs/retrospectives.md`](logs/retrospectives.md) | Per-task self-scores and reviewer verdicts |
| [`logs/handover.md`](logs/handover.md) | Session handover history |
| [`logs/verification.md`](logs/verification.md) | Verification evidence: commands run, results, artifacts |
| [`logs/failures.md`](logs/failures.md) | Failure attribution: symptom, root cause, fix, follow-up |
| [`logs/orchestration.md`](logs/orchestration.md) | Orchestration mode log for every multi-agent execution |

---

## `proposals/` — Improvement Proposals

Proposed changes to workflows, skills, or harness structure. Require approval before adoption.

See [`proposals/README.md`](proposals/README.md) for proposal formats and naming conventions.

---

## `artifacts/` — Evidence and Demo Output

Screenshots, GIFs, CLI output, test reports, and before/after comparisons produced during verification or demo-driven completion.

See [`artifacts/README.md`](artifacts/README.md) for naming conventions and storage guidance.

---

## Quick Navigation by Goal

| I want to… | Go to… |
|---|---|
| Adopt this template into a project | [`workflows/adoption.md`](workflows/adoption.md) |
| Start a new session | [`workflows/initialization.md`](workflows/initialization.md) |
| See what's in progress | [`logs/progress.md`](logs/progress.md), [`../claude-progress.md`](../claude-progress.md) |
| Find the next task | [`../feature_list.json`](../feature_list.json), [`logs/progress.md`](logs/progress.md) |
| Set up a worktree | [`workflows/worktree-sessions.md`](workflows/worktree-sessions.md) |
| Choose an execution mode | [`workflows/orchestration.md`](workflows/orchestration.md) |
| Review finished work | [`workflows/review.md`](workflows/review.md), [`../evaluator-rubric.md`](../evaluator-rubric.md) |
| Produce demo evidence | [`workflows/demo-capture.md`](workflows/demo-capture.md), [`artifacts/README.md`](artifacts/README.md) |
| Log a decision | [`logs/decisions.md`](logs/decisions.md) |
| Record a failure | [`logs/failures.md`](logs/failures.md) |
| Propose a new skill or workflow | [`proposals/README.md`](proposals/README.md) |
| Write a session handover | [`workflows/handover.md`](workflows/handover.md), [`../session-handoff.md`](../session-handoff.md) |
| Run verification | [`context/commands.md`](context/commands.md), [`logs/verification.md`](logs/verification.md) |

---

## For Harness Maintainers

The root [`../prompt.md`](../prompt.md) is the **design specification** that defines this harness (its subsystems, workflows, and rules). It is reference material for people extending or auditing the harness — not part of the per-session reading order for project agents. When adopting the template you may keep it for design intent or remove it; see [`workflows/adoption.md`](workflows/adoption.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](./README.md) and [AGENTS.md](../AGENTS.md)._
