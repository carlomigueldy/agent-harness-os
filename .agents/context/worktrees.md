# Worktrees

Reference for git worktree conventions: branch naming, directory naming, env-file handling, verification, and cleanup.

For the full step-by-step workflow, see [../workflows/worktree-sessions.md](../workflows/worktree-sessions.md).

## Why Worktrees

Every meaningful coding session should use a dedicated git worktree. This:

- Keeps the default branch clean and always runnable.
- Allows multiple features or fixes to coexist without stashing.
- Makes it safe to copy env files without risking accidental commits.
- Gives each task an isolated, verifiable environment.

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

Keep branch names short: `feat/user-auth` not `feat/add-user-authentication-system-for-login`.

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

**In-repo option:** when tooling (e.g. Claude Code via `.claude/worktrees/`) requires worktrees inside the repo, use `./worktrees/<branch-name>`. In-repo paths under `/worktrees/` are covered by `.gitignore`, and `scripts/worktree.sh create --in-repo` also adds the path to `.git/info/exclude` (local, per-clone, never committed). For an arbitrary in-repo name created by hand (e.g. `git worktree add ./claire`), run `bash scripts/worktree.sh sync-exclude` — it adds every in-repo worktree to `.git/info/exclude` so it can never be staged or committed.

> TEMPLATE NOTE: If the project uses a different worktree convention, document it here and update [../workflows/worktree-sessions.md](../workflows/worktree-sessions.md) to match.

## Creating a Worktree

**Recommended:** use the helper script — it validates the branch prefix, creates the worktree, and copies env files safely:

```bash
# Sibling (preferred, outside repo tree):
bash scripts/worktree.sh create feat/my-feature

# In-repo (./worktrees/<branch>, auto-excluded via .git/info/exclude):
bash scripts/worktree.sh create feat/my-feature --in-repo

# From a specific base ref:
bash scripts/worktree.sh create feat/my-feature --base main
```

**Manual fallback (if the helper is unavailable):**

```bash
# From the repo root:
git worktree add ../{{REPO_NAME}}-worktrees/<branch-name> -b <branch-name>

# Then copy env files (see Environment section below)
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

See [environment.md](./environment.md) for the detailed copy steps.

## Session Log Entry (Required Before Implementation)

Before starting implementation in a worktree, log this block in `../../session-handoff.md` or `../logs/progress.md`:

```md
## Worktree Session

### Branch
`<branch-name>`

### Worktree Path
`../{{REPO_NAME}}-worktrees/<branch-name>`

### Base Branch
`{{DEFAULT_BRANCH}}`

### Env Files
Copied / missing / not needed — explain.

### Git Status
Clean / dirty — explain if dirty.
```

## Verification After Setup

Before writing any code, confirm the worktree is functional:

```bash
cd ../{{REPO_NAME}}-worktrees/<branch-name>
git status          # should be clean
{{LINT_CMD}}        # should pass
{{TYPECHECK_CMD}}   # should pass
{{TEST_CMD}}        # should pass (or document known failures)
```

## Cleanup After Merging

Once the branch is merged or abandoned:

```bash
# From the repo root:
git worktree remove ../{{REPO_NAME}}-worktrees/<branch-name>
git branch -d <branch-name>   # only after merge
```

Remove any copied env files manually if the directory is not deleted.

## Related

- [../workflows/worktree-sessions.md](../workflows/worktree-sessions.md) — full step-by-step guide
- [environment.md](./environment.md) — env var setup and copy instructions
- [commands.md](./commands.md) — verification commands

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
