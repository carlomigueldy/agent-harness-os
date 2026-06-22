# GitHub Issues & PR Workflow

Manage all meaningful work through GitHub Issues and pull requests when a GitHub remote is available.

## When to Use

- Any non-trivial feature, bug fix, refactor, or harness change
- Tracking progress across sessions
- Linking verification evidence to issues
- Coordinating agent teams or dynamic workflows via shared issue state

---

## Issue Templates

Four templates live in [../../.github/ISSUE_TEMPLATE/](../../.github/ISSUE_TEMPLATE/):

| File | Purpose |
|---|---|
| [`epic.yml`](../../.github/ISSUE_TEMPLATE/epic.yml) | Large multi-task goal with sub-issues |
| [`epic-subissue.yml`](../../.github/ISSUE_TEMPLATE/epic-subissue.yml) | Scoped task within an epic |
| [`bug_report.yml`](../../.github/ISSUE_TEMPLATE/bug_report.yml) | Reproducible defect |
| [`feature_request.yml`](../../.github/ISSUE_TEMPLATE/feature_request.yml) | New user-facing capability |

### Epic — Required Fields

- Summary and goals
- Non-goals
- User value
- Scope
- Acceptance criteria
- Sub-issues (linked via `#issue-number`)
- Dependencies and blockers
- Parallel work opportunities
- Sequential constraints
- Risks
- Verification plan
- Demo requirements
- Worktree notes
- Agent-team / dynamic-workflow notes if relevant
- Reviewer scoring requirement
- Release notes stub

### Epic Sub-Issue — Required Fields

- Parent epic reference (`#issue-number`)
- Summary and scope
- Acceptance criteria
- Dependencies and blockers
- Parallel-safe: yes / no
- Worktree requirement
- Testing requirements
- Demo requirements
- Reviewer score / verdict
- Handover notes

### Bug Report — Required Fields

- Steps to reproduce
- Expected vs actual behavior
- Environment (version, OS, branch)
- Severity (Critical / Major / Minor / Nit)
- Linked feature ID from `feature_list.json`
- Verification command that reproduces the bug

### Feature Request — Required Fields

- User story or job-to-be-done
- Acceptance criteria
- Verification plan
- Priority
- Linked feature ID from `feature_list.json`

---

## Label Set

Apply labels consistently. Create them in the repo before use.

```
# type — what kind of work
type: epic
type: task
type: bug
type: chore
type: docs
type: refactor
type: test
type: command         # a .claude/commands/ slash command
type: agent-skill     # a .claude/skills/ project skill

# priority
priority: critical
priority: high
priority: medium
priority: low

# status
status: blocked
status: in-progress
status: review

# area — which harness surface (navigation)
area: harness
area: commands
area: skills
area: context
area: loops
area: ci
area: docs

# execution / process
parallel-safe
sequential-required
needs-verification
needs-demo
agent-team
dynamic-workflow
worktree-session
```

> The `type: command`, `type: agent-skill`, and `area: *` labels were added when the harness gained invokable commands/skills (see [`../logs/decisions.md`](../logs/decisions.md)). Adopters create the labels they need before first use.

---

## Linking Features to Issues

Every feature in [`../../feature_list.json`](../../feature_list.json) should have a `github_issue` field populated once an issue exists.

```json
{
  "id": "auth-login",
  "github_issue": 12
}
```

Update `feature_list.json` when:
- An issue is opened (add the issue number)
- The issue is closed (update `status` to `passing`)
- Blockers are discovered (update `blockers`)

---

## PR Workflow

### Steps

1. Create or update the relevant GitHub Issue.
2. Branch from `{{DEFAULT_BRANCH}}` using a clear name:

   ```
   feat/<short-description>
   fix/<short-description>
   docs/<short-description>
   chore/<short-description>
   refactor/<short-description>
   test/<short-description>
   harness/<short-description>
   ```

3. Create a dedicated worktree for the branch. See [`../context/worktrees.md`](../context/worktrees.md).
4. Copy required local env files safely (never stage them).
5. Implement scoped changes.
6. Run verification as much as possible (`{{LINT_CMD}}`, `{{TYPECHECK_CMD}}`, `{{TEST_CMD}}`).
7. Capture demo / evidence. See [demo-capture.md](./demo-capture.md).
8. Run reviewer feedback loop if the change is non-trivial.
9. Update harness logs (`changelog.md`, `progress.md`, `verification.md`).
10. Open PR using `gh pr create` or the GitHub UI.
11. Link PR to issue with an auto-closing keyword in the PR body:

    ```
    Closes #123
    Fixes #123
    Resolves #123
    ```

12. If an issue is already closed, reference it without re-closing: `See #123`.

### PR Description Must Include

- Summary of what changed and why
- Link to the related issue
- Verification evidence (test results, screenshots, CLI output)
- Reviewer score / verdict if a feedback loop was run
- Checklist: no secrets staged, no LLM attribution, changelog updated

### PR Description Must NOT Include

- LLM / AI attribution of any kind
- Raw session logs
- Fabricated evidence

---

## Private Repo Setup

If no GitHub remote exists and one must be created:

1. Inspect `git status` and `git remote -v`.
2. Check for secrets in staged or tracked files.
3. Use GitHub CLI if authenticated:

   ```sh
   gh repo create {{GITHUB_OWNER}}/{{REPO_NAME}} --private --source=. --push
   ```

4. Confirm repo is private: `gh repo view --json isPrivate`.
5. If `gh` is unavailable, prepare locally and provide exact commands for the human to run.
6. Never push if secrets are present. Stop and report clearly.

> TEMPLATE NOTE: Replace `{{GITHUB_OWNER}}` and `{{REPO_NAME}}` with actual values during project setup.

---

## Quick Reference

```sh
# Create issue
gh issue create --template epic.yml

# List open issues
gh issue list --state open

# Open PR
gh pr create --fill

# Link issue in PR body
Closes #<issue-number>

# View PR status
gh pr status
```

---

## Epic-Branch Delivery

For the epic-branch model, sub-issue auto-closing, ledger sync (`feature_list.json`), and the full rules, see [`epic-delivery.md`](epic-delivery.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
