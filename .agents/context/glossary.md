# Glossary

Definitions for harness terms and project-specific terminology.

## Harness Terms

| Term | Definition |
|------|-----------|
| **Agent Harness OS** | The complete set of instructions, context, workflows, logs, and tooling that makes a repo self-documenting and agent-operable across sessions. |
| **Sprint Contract** | A structured plan created before any non-trivial task. Defines goal, scope, non-goals, acceptance criteria, verification plan, demo plan, orchestration mode, and definition of done. Stored in `../logs/progress.md`. |
| **Orchestration Mode** | The execution strategy chosen for a task: Single Agent, Subagent, Agent Team, or Dynamic Workflow. Must be selected intentionally before implementation. |
| **Evaluator / Reviewer** | The agent role responsible for scoring output from 1–10 and giving a `PASS`, `REVISE`, or `BLOCK` verdict against the sprint contract and evaluator rubric. |
| **Planner** | The agent role responsible for writing the sprint contract, decomposing work, and selecting orchestration mode. |
| **Builder / Implementation Agent** | The agent role responsible for implementing the plan, running verification, and capturing evidence. |
| **Sub-issue** | A GitHub issue that is a child of an Epic. Tracks a single scoped task with its own acceptance criteria, verification, and worktree. |
| **Epic** | A GitHub issue that represents a large feature or initiative composed of multiple sub-issues. |
| **Worktree** | A git worktree — a separate checked-out branch in its own directory, allowing isolated development without switching branches in the main directory. |
| **Worktree Session** | A development session conducted inside a dedicated git worktree. The default mode for any meaningful coding task. |
| **Handover** | A compact written summary produced at the end of a session so the next session can immediately understand what happened, what is in progress, and what to do next. |
| **Demo Evidence** | A screenshot, GIF, video, CLI output, or test report that proves a user-facing feature works as intended. Required for `PASS` verdict on user-facing work. |
| **Verification Evidence** | Any artifact (test output, build log, lint output, screenshot) that confirms implementation is correct. Required before handoff. |
| **PASS** | Reviewer verdict meaning: Score 10/10, zero Critical issues, zero Major issues, verification evidence present. |
| **REVISE** | Reviewer verdict meaning: Issues found that must be fixed before the work can be accepted. Triggers another feedback loop iteration. |
| **BLOCK** | Reviewer verdict meaning: Critical or Major issues found that prevent the work from proceeding. Human review may be required. |
| **Dynamic Workflow** | A repeatable, scriptable multi-subagent orchestration pattern. Used for audits, migrations, or verification sweeps that will be run more than once. |
| **Agent Team** | Multiple Claude Code sessions collaborating on a complex task with defined roles (Lead, Architect, Builder, Tester, Reviewer, Documenter). |
| **Subagent** | A focused worker agent dispatched to investigate a narrow scope and return a summary result. Keeps the main session context clean. |
| **Context File** | A file in `.agents/context/` that provides reference information for any session without needing re-discovery. |
| **Model Tiering** | Using cheaper models for low-complexity tasks, stronger for architecture/review. Full tier table and role assignments: [subagents.md → Model Tiering](subagents.md). |
| **Clean State** | The condition of the repo at session end: no staged secrets, no uncommitted env files, progress updated, handover written, next action clear. |
| **Harness Debt** | Gaps, stale content, or missing workflows in the agent harness. Treated like technical debt — tracked and improved. |
| **Feedback Loop** | The iterative Plan → Implement → Verify → Review → Revise cycle. Continues until Reviewer gives 10/10 PASS or max iterations (6) are reached. |

## Project-Specific Terms

<!-- FILL: Add domain-specific or project-specific vocabulary that a new agent or developer must know -->

| Term | Definition |
|------|-----------|
| <!-- FILL --> | <!-- FILL --> |

> TEMPLATE NOTE: Add terms from the project's domain (e.g. DeFi terms, SaaS concepts, proprietary module names) that would not be obvious to a new contributor. Keep definitions concise — one or two sentences each.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
