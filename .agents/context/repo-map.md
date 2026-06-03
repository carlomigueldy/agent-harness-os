# Repo Map

High-level map of repository directories, entry points, and structural purpose.

## Top-Level Directory Table

| Path | Purpose |
|------|---------|
| `/` | Repo root — AGENTS.md, CLAUDE.md, init.sh, feature tracker, session files |
| `.agents/` | Harness OS — context, workflows, logs, proposals, artifacts |
| `.agents/context/` | Reference context for every session (this directory) |
| `.agents/workflows/` | Step-by-step workflow guides for every phase of work |
| `.agents/logs/` | Persistent log files: decisions, changelog, learnings, progress |
| `.agents/proposals/` | Pending harness improvement and skill proposals |
| `.agents/artifacts/` | Demo screenshots, GIFs, test reports, and evidence files |
| `.github/` | GitHub issue templates and pull request template |
| `.github/ISSUE_TEMPLATE/` | Structured issue forms: epic, sub-issue, bug, feature |

<!-- FILL: Add project-specific directories below once discovered (e.g. src/, apps/, packages/, backend/, contracts/) -->

> TEMPLATE NOTE: Replace the table above with your actual directory tree. Include every top-level directory that a new session should know about — app source, config, infra, scripts, tests, docs. Keep descriptions to one line.

## Application Entry Points

<!-- FILL: List the primary entry files for each application or service in this repo -->

| Entry Point | Type | Notes |
|-------------|------|-------|
| <!-- FILL: e.g. src/main.ts --> | <!-- FILL: e.g. Server, CLI, Worker --> | <!-- FILL --> |

> TEMPLATE NOTE: Add one row per runnable entry point. For monorepos, list each app's entry. For libraries, list the public exports file.

## Key Configuration Files

<!-- FILL: List config files that are especially important for a new session to know about -->

| File | Purpose |
|------|---------|
| <!-- FILL: e.g. package.json / pyproject.toml --> | Package manifest and scripts |
| <!-- FILL: e.g. .env.example --> | Environment variable template |
| <!-- FILL: e.g. tsconfig.json / setup.cfg --> | Language/toolchain config |

## Source of Truth for Commands

All runnable commands live in [commands.md](./commands.md). Do not duplicate them here.

## Related Context

- [project-brief.md](./project-brief.md) — what the project is and why it exists
- [architecture.md](./architecture.md) — system design and patterns
- [environment.md](./environment.md) — runtime, install steps, env vars

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
