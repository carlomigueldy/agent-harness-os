# Agent Teams

Coordinate multiple Claude Code sessions for complex work that benefits from specialized roles.

## When to Use

Use an agent team only when all of the following are true:

- The task is complex enough to justify coordination overhead
- Workstreams are independent but related, with clear ownership boundaries
- Multiple agents need to share findings directly or challenge each other's assumptions
- One context window would be a bottleneck
- The work benefits from specialized roles (design, build, test, review)

Good use cases:

- Designing a new feature across frontend, backend, contracts, and tests
- Large refactors with separate ownership boundaries
- Parallel code review (security, architecture, tests, UX reviewers)
- Complex debugging with competing hypotheses
- Multi-module implementation where each teammate owns a separate area
- Harness audits where teammates review instructions, tools, environment, state, and feedback separately

**When NOT to use a team:**

- The task is simple or medium-sized
- Teammates would edit the same files
- The task is mostly sequential
- The project lacks enough context for safe delegation
- Token budget is constrained
- Coordination cost exceeds the implementation cost

---

## Role Definitions

| Role | Responsibility | Can Edit? |
|---|---|---|
| **Lead / Coordinator** | Owns task list, assigns work, prevents overlap, synthesizes results, makes final integration decisions | No (coordination only) |
| **Architect** | Reviews design, identifies cross-cutting risks, ensures solution fits the project | No (advisory) |
| **Builder** | Implements scoped changes within assigned files/modules, runs targeted verification | Yes (assigned scope only) |
| **Tester** | Writes and runs tests, captures verification evidence | Yes (test files only) |
| **Reviewer** | Scores against evaluator rubric, gives PASS / REVISE / BLOCK verdict, finds Critical/Major/Minor/Nit issues | No |
| **Documenter** | Updates AGENTS.md, CLAUDE.md, changelog, handover, and feature state | Yes (docs only) |

Not all roles are required for every team. Use only the roles the task needs.

---

## Agent Team Assessment

Before starting, the lead must complete this assessment and store it in [../logs/progress.md](../logs/progress.md):

```md
## Agent Team Assessment — YYYY-MM-DD — Task Name

### Why a Team Is Needed
Explain why a single agent or subagents are not enough.

### Team Goal
What the team must deliver.

### Proposed Roles
- Lead:
- Architect:
- Builder:
- Tester:
- Reviewer:
- Documenter:

### Work Partitioning
| Role | Owned Area | Files/Modules | Can Edit? | Verification Required | Notes |
|---|---|---|---:|---|---|
| Lead | Coordination | N/A | No | Synthesis check | Synthesizes results |
| Builder | Feature implementation | `src/...` | Yes | Targeted tests/build | Owns implementation |
| Tester | Verification | `tests/...` | Yes | Test evidence | Owns test coverage |
| Reviewer | Review | Diff/docs/evidence | No | Rubric score | Gives verdict |

### Communication Plan
How teammates share findings (handover notes, log entries, direct synthesis).

### Conflict Avoidance
How file overlap and merge conflicts will be avoided.

### Worktree Plan
Which worktree each editing teammate uses.

### Env File Plan
Whether env files are needed and where they are copied from.

### Verification Plan
How implementation agents verify their own work and how the reviewer verifies final output.

### Reviewer Feedback Loop
How 10/10 scoring and PASS / REVISE / BLOCK verdicts will work.
Max iterations: 6.
Pass requires: Score 10/10, Verdict PASS, 0 Critical, 0 Major, evidence present.

### Cost Justification
Why this is worth the extra token/session cost.

### Fallback Plan
What to do if the team becomes inefficient (collapse to single agent, record reason).
```

---

## Reviewer Feedback Loop

Every non-trivial agent team task must include an autonomous feedback loop:

1. Planner defines acceptance criteria.
2. Builders implement and verify their own work.
3. Reviewer evaluates all output.
4. Reviewer scores 1–10 and gives verdict: `PASS` / `REVISE` / `BLOCK`.
5. Critical and Major issues are fixed.
6. Loop repeats until `Score: 10/10` + `Verdict: PASS`, or 6 iterations are reached.

**Pass requires all of:**

```
Score: 10/10
Verdict: PASS
Critical issues: 0
Major issues: 0
Verification evidence: present or clearly justified
No secrets staged: confirmed
No LLM attribution: confirmed
Progress/changelog/handover updated: confirmed
```

If iteration 6 is reached and Critical or Major issues remain, do not ship. Document remaining issues and create follow-up GitHub Issues.

---

## Worktree and File Ownership

Each editing agent (Builder, Tester, Documenter) must have:

- Assigned branch
- Assigned worktree path (sibling dir: `../{{REPO_NAME}}-worktrees/<branch>`)
- Assigned files/modules (no overlapping edits)
- Clear verification responsibility
- Clear handover responsibility

See [worktree-sessions.md](./worktree-sessions.md) for worktree setup and env file handling.

After all teammates finish, the Lead runs final integration verification:

```sh
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}}
{{BUILD_CMD}}
```

---

## Orchestration Log

After the team completes work, append to [../logs/orchestration.md](../logs/orchestration.md) using the format in [orchestration.md](./orchestration.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
