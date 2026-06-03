# Troubleshooting

Common problems and their fixes. Each entry has a Problem, Symptom, and Fix.

---

## Worktree Missing Env Files

**Problem:** Session worktree was created but env files were not copied from the main worktree.

**Symptom:** Dev server or tests fail immediately with `Missing required env var: <VAR>` or similar config errors.

**Fix:**
```bash
# Find env files in the main worktree
ls /path/to/main-worktree/.env*

# Copy each to the session worktree at the same relative path
cp /path/to/main-worktree/.env /path/to/session-worktree/.env

# Verify it is gitignored
git -C /path/to/session-worktree check-ignore -v .env

# Confirm it is not staged
git -C /path/to/session-worktree status
```

See [environment.md](./environment.md) for the full env-copy protocol and [worktrees.md](./worktrees.md) for worktree setup.

---

## Verification Command Not Found — Check commands.md Placeholders

**Problem:** A `{{*_CMD}}` placeholder was not replaced with a real command during harness initialization.

**Symptom:** Running `{{LINT_CMD}}` or similar literally in the shell produces `command not found` or bash parse errors.

**Fix:**
1. Open [commands.md](./commands.md).
2. Identify which `{{*_CMD}}` placeholders are still unfilled.
3. Discover the real command from `package.json` scripts, `Makefile`, or project docs.
4. Replace the placeholder with the real command.
5. Run the command to verify it works.

---

## Install Fails with Dependency Conflicts

**Problem:** `{{INSTALL_CMD}}` exits with peer dependency or version conflict errors.

**Symptom:** Error messages mentioning `ERESOLVE`, `incompatible peer`, or `resolution failed`.

**Fix:**
<!-- FILL: Add project-specific fix if known. General guidance below. -->
- Check that your runtime version matches the required version in [environment.md](./environment.md).
- Try clearing the package manager cache: <!-- FILL: e.g. `npm cache clean --force` or `pip cache purge` -->
- Check for a lock file conflict (`.lock` file from a different package manager).
- If the project uses a version manager (nvm, pyenv, asdf), ensure the correct version is active.

---

## Tests Fail in Worktree But Pass in Main

**Problem:** Tests pass on the default branch but fail after creating a worktree.

**Symptom:** Test errors related to database connection, missing fixtures, or environment config.

**Fix:**
- Confirm env files were copied correctly (see "Worktree Missing Env Files" above).
- Confirm dependencies are installed in the worktree: `{{INSTALL_CMD}}`
- Check that the database is running and migrations have been applied: <!-- FILL: see commands.md -->
- Check for absolute path hardcoding in test fixtures or config files.

---

## Git Worktree Already Exists Error

**Problem:** Attempting to create a worktree for a branch that already has one.

**Symptom:** `fatal: '<branch>' is already checked out at '<path>'`

**Fix:**
```bash
# List existing worktrees
git worktree list

# If the old worktree is stale, remove it
git worktree remove /path/to/old-worktree

# Then create the new worktree
git worktree add ../{{REPO_NAME}}-worktrees/<branch> -b <branch>
```

---

## Build Fails After Switching Branches in Worktree

**Problem:** The build fails with stale cache or mismatched generated files after branching.

**Symptom:** Type errors for missing generated types, stale `.next/`, `dist/`, or `__pycache__` artifacts.

**Fix:**
```bash
# Remove build artifacts
# <!-- FILL: e.g. rm -rf .next dist __pycache__ -->

# Reinstall dependencies (in case lockfile changed)
{{INSTALL_CMD}}

# Rebuild
{{BUILD_CMD}}
```

---

## How to Add a New Entry

When you fix a problem that took more than 2 minutes to diagnose:

1. Add an entry here using the **Problem / Symptom / Fix** format.
2. Keep the fix actionable — exact commands preferred.
3. Link to the relevant context file if it provides more detail.
4. If the problem reveals a harness gap, create a proposal in `../proposals/`.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
