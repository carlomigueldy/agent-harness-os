# Worktree Sessions

Every meaningful coding session should use a dedicated git worktree.

## When to Use

- Starting any non-trivial feature, fix, refactor, or harness change
- Any time you would otherwise work directly on `{{DEFAULT_BRANCH}}`
- When an agent team assigns editing roles to multiple agents
- When a dynamic workflow has implementation workers

If worktrees are not possible (e.g., git worktree not supported, disk constraints), explain why and continue on a normal branch with extra care.

---

## Branch Naming

```
feat/<short-description>
fix/<short-description>
docs/<short-description>
chore/<short-description>
refactor/<short-description>
test/<short-description>
harness/<short-description>
```

Keep names lowercase, hyphen-separated, and under 40 characters.

---

## Worktree Directory Convention

Use a predictable sibling directory:

```
../{{REPO_NAME}}-worktrees/<branch-name>
```

Example:

```
../my-app-worktrees/feat/auth-refresh-token
```

<!-- FILL: If the project uses a different worktree convention, document it here -->

---

## Creating a Worktree

```sh
# From the repo root
git worktree add ../{{REPO_NAME}}-worktrees/<branch-name> -b <branch-name>

# Verify it was created
git worktree list
```

---

## Copying Environment Files Safely

When the session worktree needs local env files, copy them from the default branch worktree or from the nearest existing worktree where env files already exist.

Common env files to copy:

```
.env
.env.local
.env.development
.env.test
.env.production.local
apps/*/.env
packages/*/.env
```

### Safe Copy Procedure

```sh
# 1. Identify env files in the source worktree (default branch or existing)
find /path/to/source-worktree -name ".env*" -not -path "*/.git/*"

# 2. Copy each file to the same relative path in the session worktree
cp /path/to/source/.env /path/to/session-worktree/.env

# 3. Verify each copied file is gitignored
cd /path/to/session-worktree
git check-ignore -v .env
git check-ignore -v .env.local
# (should return the .gitignore rule — if not, stop and fix .gitignore)

# 4. Confirm nothing is staged
git status
# Env files must NOT appear in staging
```

### Rules — Non-Negotiable

- Copy env files only for local development and verification.
- **Never commit copied env files.**
- Ensure `.gitignore` ignores all copied files before copying.
- **Do not print secret values** in logs, terminal output, or file contents shared with others.
- **Do not expose secret values** in progress notes or handover documents.
- **Do not overwrite** an existing env file in the worktree without checking its contents first.
- If env files are missing, document what is missing and continue with safe non-secret verification where possible.

---

## Worktree Session Log

Before implementation starts, record the session in [../logs/progress.md](../logs/progress.md):

```md
## Worktree Session — YYYY-MM-DD — Task Name

### Branch
`branch-name`

### Worktree Path
`../{{REPO_NAME}}-worktrees/<branch-name>`

### Base Branch
`{{DEFAULT_BRANCH}}`

### Env Files
Copied / missing / not needed.
(List file names only — no values.)

### Git Status
Clean / dirty — explain if dirty.
```

---

## Verifying Worktree State

Before starting implementation:

```sh
# Confirm you are in the correct worktree
git worktree list

# Confirm the branch is correct
git branch --show-current

# Confirm working tree is clean
git status

# Confirm env files are not staged
git diff --cached --name-only | grep -E "\.env"
# Should return nothing
```

---

## During Implementation

- Stay within the assigned scope. Do not edit files outside your assigned area without explicit approval.
- Run targeted verification after each meaningful change:

  ```sh
  {{LINT_CMD}}
  {{TYPECHECK_CMD}}
  {{TEST_CMD}}
  ```

- Do not stage or commit env files.
- Update `../logs/progress.md` as work proceeds.

---

## Cleanup

After merging or opening a PR:

```sh
# Remove the worktree
git worktree remove ../{{REPO_NAME}}-worktrees/<branch-name>

# Optionally prune stale worktree references
git worktree prune

# Delete the branch if merged
git branch -d <branch-name>
```

Do not force-delete a branch that has unmerged work unless explicitly approved.

---

## Merging or Opening a PR Safely

1. Run full verification in the worktree:

   ```sh
   {{LINT_CMD}} && {{TYPECHECK_CMD}} && {{TEST_CMD}} && {{BUILD_CMD}}
   ```

2. Confirm no env files are staged: `git diff --cached --name-only`.
3. Confirm no secrets are staged: review `git diff --cached`.
4. Push the branch: `git push -u origin <branch-name>`.
5. Open a PR. See [github-issues.md](./github-issues.md) for the PR workflow.
6. Do not merge directly to `{{DEFAULT_BRANCH}}` without review unless the task scope is trivial and explicitly approved.

---

## Multiple Worktrees for Agent Teams

When an agent team assigns editing roles to multiple agents:

- Each editing agent gets its own branch and worktree.
- Worktree paths must be distinct:

  ```
  ../{{REPO_NAME}}-worktrees/feat/auth-builder
  ../{{REPO_NAME}}-worktrees/feat/auth-tester
  ```

- File ownership must be agreed before any agent begins editing.
- Lead runs integration verification after all branches are merged.

See [agent-teams.md](./agent-teams.md) for the full team workflow.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
