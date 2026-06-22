# Worktrees

Reference for git worktree conventions: branch naming, directory naming, lifecycle, env-file handling, verification, multi-worktree coordination, and cleanup.

## Why Worktrees

Every meaningful coding session should use a dedicated git worktree. This:

- Keeps the default branch clean and always runnable.
- Allows multiple features or fixes to coexist without stashing.
- Makes it safe to copy env files without risking accidental commits.
- Gives each task an isolated, verifiable environment.

## When to Use

- Starting any non-trivial feature, fix, refactor, or harness change.
- Any time you would otherwise work directly on `{{DEFAULT_BRANCH}}`.
- When an agent team assigns editing roles to multiple agents.
- When a dynamic workflow has implementation workers.

If worktrees are not possible (e.g. git worktree not supported, disk constraints), explain why and continue on a normal branch with extra care.

## Branch Naming

| Prefix | Use for | Example |
|--------|---------|---------|
| `feat/` | New features | `feat/user-auth` |
| `fix/` | Bug fixes | `fix/null-payment-response` |
| `docs/` | Documentation-only | `docs/update-api-reference` |
| `chore/` | Tooling, deps, config | `chore/upgrade-eslint` |
| `refactor/` | Code restructuring | `refactor/extract-auth-module` |
| `test/` | Adding or fixing tests | `test/cover-payment-service` |
| `harness/` | Agent harness improvements | `harness/add-workflow-context` |

Keep branch names lowercase, hyphen-separated, and under 40 characters: `feat/user-auth` not `feat/add-user-authentication-system-for-login`.

Default branch: `{{DEFAULT_BRANCH}}`

## Worktree Directory Naming

**Preferred:** sibling directories outside the repo tree (nothing to ignore):

```
../{{REPO_NAME}}-worktrees/<branch-name>
```

**Example:**

```
../my-app-worktrees/feat/user-auth
../my-app-worktrees/fix/null-payment-response
```

**In-repo option:** when tooling (e.g. Claude Code via `./worktrees/`) requires worktrees inside the repo, use `./worktrees/<branch-name>`. In-repo paths under `/worktrees/` are covered by `.gitignore`, and `scripts/worktree.sh create --in-repo` also adds the path to `.git/info/exclude` (local, per-clone, never committed). For an arbitrary in-repo name created by hand (e.g. `git worktree add ./claire`), run `bash scripts/worktree.sh sync-exclude` — it adds every in-repo worktree to `.git/info/exclude` so it can never be staged or committed.

> TEMPLATE NOTE: If the project uses a different worktree convention, document it here.

## Creating a Worktree

**Recommended:** use the helper script — it validates the branch prefix, creates the worktree, and copies env files safely:

```bash
# Sibling (preferred, outside repo tree):
bash scripts/worktree.sh create feat/my-feature

# In-repo (./worktrees/<branch>, auto-excluded via .git/info/exclude):
bash scripts/worktree.sh create feat/my-feature --in-repo

# From a specific base ref:
bash scripts/worktree.sh create feat/my-feature --base main

# List all worktrees:
bash scripts/worktree.sh list
```

**Manual fallback (if the helper is unavailable):**

```bash
# From the repo root:
git worktree add ../{{REPO_NAME}}-worktrees/<branch-name> -b <branch-name>

# Verify it was created
git worktree list

# Then copy env files (see Environment File Rules below)
# Then install dependencies if needed
cd ../{{REPO_NAME}}-worktrees/<branch-name>
{{INSTALL_CMD}}
```

## Environment File Rules

Env files must be copied from the main worktree or the nearest worktree where they exist.

| Rule | Detail |
|------|--------|
| Copy, do not symlink | Symlinks can accidentally expose changes across worktrees |
| Verify gitignored | Run `git check-ignore -v .env` in the worktree |
| Never stage | Confirm `git status` shows env files as untracked or ignored |
| Never print values | Do not log or echo secret contents |
| Do not overwrite | Check if the file already exists before copying |
| Document gaps | If missing, note it in the session log and continue with safe verification |

Env files to look for:

```
.env
.env.local
.env.development
.env.test
.env.production.local
apps/*/.env
packages/*/.env
```

For the full copy procedure, see [environment.md → Copying Env Files into a Worktree](./environment.md).

## Session Log Entry (Required Before Implementation)

Before starting implementation in a worktree, log this block in `../../session-handoff.md` or `../logs/progress.md`:

```md
## Worktree Session — YYYY-MM-DD — Task Name

### Branch
`<branch-name>`

### Worktree Path
`../{{REPO_NAME}}-worktrees/<branch-name>`

### Base Branch
`{{DEFAULT_BRANCH}}`

### Env Files
Copied / missing / not needed — list file names only, no values.

### Git Status
Clean / dirty — explain if dirty.
```

## Verification After Setup

Before writing any code, confirm the worktree is functional:

```bash
# Confirm you are in the correct worktree and on the right branch
git worktree list
git branch --show-current

# Confirm working tree is clean
git status

# Confirm env files are not staged
git diff --cached --name-only | grep -E "\.env"
# Should return nothing

{{LINT_CMD}}        # should pass
{{TYPECHECK_CMD}}   # should pass
{{TEST_CMD}}        # should pass (or document known failures)
```

## During Implementation

- Stay within the assigned scope — do not edit files outside your assigned area without explicit approval.
- Run targeted verification after each meaningful change:

  ```bash
  {{LINT_CMD}}
  {{TYPECHECK_CMD}}
  {{TEST_CMD}}
  ```

- Do not stage or commit env files.
- Update `../logs/progress.md` as work proceeds.

## Merging or Opening a PR

Before opening a PR or merging:

1. Run full verification in the worktree:

   ```bash
   {{LINT_CMD}} && {{TYPECHECK_CMD}} && {{TEST_CMD}} && {{BUILD_CMD}}
   ```

2. Confirm no env files are staged: `git diff --cached --name-only`.
3. Confirm no secrets are staged: review `git diff --cached`.
4. Push the branch: `git push -u origin <branch-name>`.
5. Open a PR — see [../workflows/github-issues.md](../workflows/github-issues.md) for the PR workflow.
6. Do not merge directly to `{{DEFAULT_BRANCH}}` without review unless the scope is trivial and explicitly approved.

## Cleanup After Merging

Once the branch is merged or abandoned:

```bash
# Helper (safe — refuses if uncommitted changes or unmerged commits):
bash scripts/worktree.sh remove feat/my-feature
bash scripts/worktree.sh remove feat/old-wip --force   # override safety checks
bash scripts/worktree.sh prune                         # remove stale metadata
```

**Manual fallback:**

```bash
# From the repo root:
git worktree remove ../{{REPO_NAME}}-worktrees/<branch-name>

# Prune stale worktree references
git worktree prune

# Delete the branch if merged
git branch -d <branch-name>   # only after merge
```

Do not force-delete a branch that has unmerged work unless explicitly approved. Remove any copied env files manually if the directory is not deleted.

## Multiple Worktrees (Agent Teams)

When an agent team assigns editing roles to multiple agents:

- Each editing agent gets its own branch and worktree.
- Worktree paths must be distinct:

  ```
  ../{{REPO_NAME}}-worktrees/feat/auth-builder
  ../{{REPO_NAME}}-worktrees/feat/auth-tester
  ```

- File ownership must be agreed before any agent begins editing.
- Lead agent runs integration verification after all branches are merged.

See [../workflows/agent-teams.md](../workflows/agent-teams.md) for the full team workflow.

## Related

- [environment.md](./environment.md) — env var setup and copy procedure
- [commands.md](./commands.md) — verification commands

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
