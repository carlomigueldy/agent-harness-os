# Commands

**Single source of truth for all runnable shell/CLI commands** (install, build, test, deploy). Every other doc links here; do not duplicate commands elsewhere.

> **Disambiguation:** This file covers shell commands you run in a terminal. For Claude Code slash commands (`/build-loop`, `/review-10x`, etc.), see [`slash-commands.md`](slash-commands.md).

## Core Command Reference

| Purpose | Command | Notes |
|---------|---------|-------|
| Install dependencies | `{{INSTALL_CMD}}` | Run after cloning or pulling new deps |
| Start dev server | `{{DEV_CMD}}` | Local development with hot-reload |
| Build for production | `{{BUILD_CMD}}` | Produces optimized output |
| Lint | `{{LINT_CMD}}` | Fix lint errors before committing |
| Typecheck | `{{TYPECHECK_CMD}}` | Must pass; do not skip |
| Unit tests | `{{TEST_CMD}}` | Run targeted tests during implementation |
| Integration tests | <!-- FILL: e.g. `npm run test:integration` --> | <!-- FILL: notes on scope or database requirements --> |
| E2E tests | `{{E2E_CMD}}` | Requires dev server running unless CI mode |
| Format | `{{FORMAT_CMD}}` | Auto-format before committing |
| Database migrations (run) | <!-- FILL: e.g. `npm run db:migrate` --> | <!-- FILL: e.g. requires DATABASE_URL --> |
| Database migrations (create) | <!-- FILL: e.g. `npm run db:migrate:create <name>` --> | <!-- FILL --> |
| Database seed | <!-- FILL: e.g. `npm run db:seed` --> | <!-- FILL: safe to run in dev only --> |
| Contract tests | <!-- FILL: e.g. `npm run test:contracts` --> | <!-- FILL: blockchain/contract projects only --> |
| Contract compile | <!-- FILL: e.g. `npm run compile` --> | <!-- FILL: blockchain/contract projects only --> |
| Contract deploy (local) | <!-- FILL: e.g. `npm run deploy:local` --> | <!-- FILL --> |
| Storybook / design system | <!-- FILL: e.g. `npm run storybook` --> | <!-- FILL: UI component development --> |
| Smoke tests | <!-- FILL: e.g. `npm run test:smoke` --> | <!-- FILL: runs against deployed env --> |
| Deploy (staging) | <!-- FILL: e.g. `npm run deploy:staging` --> | <!-- FILL: requires env vars / auth --> |
| Deploy (production) | <!-- FILL: e.g. `npm run deploy:prod` --> | <!-- FILL: requires approval + secrets --> |

> TEMPLATE NOTE: Replace every `<!-- FILL -->` and `{{*_CMD}}` placeholder with the real command once discovered. Remove rows for commands that do not apply to this project. Add project-specific commands below.

## Project-Specific Commands

<!-- FILL: Add any commands that do not fit the table above — scripts, generators, admin tasks, etc. -->

| Purpose | Command | Notes |
|---------|---------|-------|
| <!-- FILL --> | <!-- FILL --> | <!-- FILL --> |

## Verification Sequence (Minimum Before Handoff)

For most implementation tasks, run in this order before handing off:

```bash
{{LINT_CMD}}
{{TYPECHECK_CMD}}
{{TEST_CMD}}
{{BUILD_CMD}}
```

The canonical harness self-check — the same command CI runs — is:

```bash
bash scripts/verify-harness.sh        # human-readable; exits non-zero on any failure
bash scripts/verify-harness.sh --json # machine-readable for agent parsing
```

> If any command is unavailable or fails due to environment gaps, document the failure in [../logs/verification.md](../logs/verification.md) and explain what risk remains.

## Notes

- All commands assume you are in the **repo root** unless otherwise noted.
- For monorepos, prefix with the workspace filter (e.g. `--filter=web`). <!-- FILL: adjust for actual monorepo tooling -->
- E2E tests require the dev server to be running. Check [environment.md](./environment.md) for setup.
- Never run production deploys in a worktree session without explicit approval.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
