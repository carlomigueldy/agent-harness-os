# Troubleshooting

Common problems and their fixes. Each entry has a Problem, Symptom, and Fix.

---

## Worktree Missing Env Files

**Problem:** Session worktree was created but env files were not copied from the main worktree.

**Symptom:** Dev server or tests fail immediately with `Missing required env var: <VAR>` or similar config errors.

**Fix:** Follow the copy procedure in [environment.md → Copying Env Files into a Worktree](./environment.md). See [worktrees.md → Environment File Rules](./worktrees.md) for the rules.

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
