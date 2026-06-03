# Workflow Improvement

Propose new skills, improve existing ones, and safely evolve the harness.

## When to Use

- You notice the same multi-step task being done repeatedly across sessions
- A workflow step is error-prone, slow, or unclear
- A new skill could replace a repeated ad hoc pattern
- A harness file is stale, incomplete, or misleading
- A core workflow needs a material change

---

## Rules

- **Do not silently mutate core workflows.** If you find a meaningful improvement, propose it first.
- **Major changes require approval.** Create a proposal; do not apply it unilaterally.
- Minor, low-risk corrections (typos, broken links, stale command names) can be applied directly. Document them in [../logs/changelog.md](../logs/changelog.md).

---

## When to Propose a New Skill

Propose a new skill when you observe any of the following:

- The same sequence of steps appears in 2+ sessions
- An agent has to rediscover the same pattern each time
- A task has a clear, repeatable trigger and a defined output
- A skill would save meaningful time or reduce errors

Examples of skills worth proposing:

- Add a feature to a specific module
- Debug a failing test in the project's test framework
- Create a GitHub epic and sub-issues
- Capture a frontend demo screenshot
- Run full verification (`lint + typecheck + test + build`)
- Prepare a compact handover
- Review a PR against the evaluator rubric
- Audit project context for freshness
- Run a dynamic workflow for repo-wide checks
- Create a worktree and copy env files safely
- Run `/frontend-design` review for UI changes
- Select and apply the relevant `/superpowers:*` skill

---

## Skill / Workflow Proposal Format

Save proposals to [../proposals/](../proposals/) as `<skill-or-workflow-name>.md`:

```md
# Proposal: Skill or Workflow Name

## Problem
What repeated task or failure does this solve?

## Proposed Skill / Workflow
What should be created?

## Trigger
When should agents use it?

## Inputs
What information does it need?

## Steps
How should it work?

## Expected Benefit
How it improves speed, quality, cost, or reliability.

## Risks
What could go wrong?

## Requires Approval
Yes.
```

---

## Harness Improvement Proposal Format

Use this format when the improvement targets a harness file, log format, or workflow structure:

```md
# Proposal: Title

## Problem
What is inefficient, risky, unclear, repetitive, or low-quality?

## Proposed Change
What should change?

## Expected Benefit
How this improves speed, quality, cost, or reliability.

## Risks
What could go wrong?

## Migration Plan
How to adopt safely.
(e.g., update existing files, add a new file, deprecate old section)

## Requires Approval
Yes.
```

---

## After Approval

When a proposal is approved:

1. Implement the skill or harness change.
2. Update [../logs/changelog.md](../logs/changelog.md) with a `### Tooling` or `### Docs` entry.
3. Update [../logs/decisions.md](../logs/decisions.md) with the decision and rationale.
4. Update the proposal's `**Status:**` line to `Adopted` (per [../proposals/README.md](../proposals/README.md)).
5. Update [../context/skills.md](../context/skills.md) if a new skill was added.

---

## Proposals Index

All pending and approved proposals live in [../proposals/](../proposals/).

See [../proposals/README.md](../proposals/README.md) for the index and status of all proposals.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
