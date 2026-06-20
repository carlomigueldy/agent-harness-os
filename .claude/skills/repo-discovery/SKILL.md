---
name: repo-discovery
description: Inventory an unfamiliar repo (stack, build/test/lint commands, CI, docs, gaps) into a structured discovery report
---

# Skill: repo-discovery

## Purpose

Produce a structured Discovery Report for an unfamiliar repository so an agent can work safely without re-deriving the basics each session. Covers the stack, all actionable commands, CI pipeline shape, documentation state, and outstanding gaps — giving the next phase (planning, implementation, or orchestration) a verified, shared foundation to build on.

See the [initialization workflow](../../../.agents/workflows/initialization.md) for how discovery fits into a full session start.

## When to Use

- Starting work on a repo you have not touched before (or not touched recently).
- Opening any non-trivial session where repo knowledge may be stale.
- Before `/gated-orchestration` kicks off implementation — confirm the repo is understood before delegating work.
- When a teammate or agent hands off with only "here is the branch" and no context.

## When Not to Use

- The repo has a current, accurate `AGENTS.md` and `CLAUDE.md` already read in this session — skip re-deriving what is already documented.
- A tiny single-file change with obvious scope (e.g., a typo fix in a known file).
- You only need a subset of context (e.g., just the test command) — read the relevant file directly rather than running the full discovery pass.

For keeping existing context files accurate over time, use the [`../context-mapping/SKILL.md`](../context-mapping/SKILL.md) skill instead.

## Inputs

- Access to the repository root (read, bash).
- No prior assumptions about the stack or tooling.

## Outputs

- A filled **Discovery Report** (see Procedure step 5) committed or written to `.agents/logs/discovery.md` (create the file if it does not exist).
- A summary returned to the caller for immediate use.

## Procedure

1. **Detect the stack from manifest files.**
   Scan the root (and `apps/`, `packages/`, `services/` if present) for:
   `package.json`, `pnpm-workspace.yaml`, `yarn.lock`, `pyproject.toml`, `setup.py`, `requirements.txt`, `go.mod`, `Cargo.toml`, `Gemfile`, `build.gradle`, `pom.xml`, `Dockerfile`, `docker-compose.yml`, `Makefile`, `.nvmrc`, `.tool-versions`.
   Record the primary language(s), runtime version constraints, and monorepo structure (if any).

2. **Find all actionable commands.**
   From manifests, `Makefile` targets, `scripts/` directory, and `README.md`, extract and verify:
   - **Install:** `npm install`, `pip install`, `cargo build`, etc.
   - **Dev/run:** local server or REPL start command.
   - **Build:** production build command and output artifact location.
   - **Lint / format:** linter invocation and config file.
   - **Typecheck:** if the language supports it.
   - **Test:** unit, integration, E2E commands and test runner config.
   Note which commands are confirmed runnable vs. inferred from config only.

3. **Inspect CI, issue templates, and existing docs.**
   - Read `.github/workflows/` (or `.circleci/`, `.gitlab-ci.yml`, `Jenkinsfile`) — note trigger conditions, required checks, deployment steps.
   - Check `.github/ISSUE_TEMPLATE/` and `PULL_REQUEST_TEMPLATE.md` for contribution conventions.
   - Read `README.md`, `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `docs/`, and any `{{PROJECT_NAME}}.md` or architecture docs.
   - Note the branch naming convention, PR process, and merge strategy if stated.

4. **Identify gaps.**
   For each of the following, record `present`, `missing`, or `stale`:
   - `AGENTS.md` / `CLAUDE.md` context files (root and key subdirectories).
   - `.agents/` harness directory and its subdocs.
   - Test coverage (are there any tests? are they run in CI?).
   - Documentation (README complete? API docs? architecture diagram?).
   - Environment setup guide (`.env.example` or equivalent).
   - Security configuration (secrets scanning in CI? `.gitignore` covers `.env`?).

5. **Emit the Discovery Report.**
   Write a report with these sections to `.agents/logs/discovery.md`:

   ```
   # Discovery Report — {{PROJECT_NAME}}
   Date: {{DATE}}

   ## Summary
   One-paragraph orientation: what this repo is, primary language/framework, monorepo or single app, current health signal.

   ## Stack
   | Dimension       | Value |
   |-----------------|-------|
   | Language        |       |
   | Runtime version |       |
   | Framework(s)    |       |
   | Package manager |       |
   | Monorepo tool   |       |

   ## Commands
   | Purpose    | Command | Verified? |
   |------------|---------|-----------|
   | Install    |         |           |
   | Dev        |         |           |
   | Build      |         |           |
   | Lint       |         |           |
   | Typecheck  |         |           |
   | Test       |         |           |

   ## CI Pipeline
   Tool: <name>
   Trigger(s): <push/PR/schedule>
   Required checks: <list>
   Deployment: <description or "none">

   ## Gaps
   | Area        | Status  | Notes |
   |-------------|---------|-------|
   | AGENTS.md   |         |       |
   | Tests       |         |       |
   | Docs        |         |       |
   | .env guide  |         |       |
   | Secrets CI  |         |       |

   ## Risks
   Any immediate risks to working safely (missing `.gitignore`, no CI, secrets in history, etc.).

   ## Recommended Next Steps
   Ordered list of actions before starting implementation.
   ```

## Checks

- Every command in the Commands table was either run to confirm it works, or explicitly flagged `Verified? No` with a note on why it was not run.
- All manifest files present at root were read, not guessed.
- The Gaps table has a row for each area listed in step 4 — no row is blank.
- The report was written to `.agents/logs/discovery.md` (create path if missing).
- No secrets, tokens, or credentials appear anywhere in the report.

## Common Failure Modes

- **Assuming a command from memory** — always read the actual manifest. Package names and script aliases differ per project.
- **Skipping subdirectories in a monorepo** — each workspace (`apps/`, `packages/`) may have its own stack entry and scripts.
- **Marking gaps as "missing" without checking** — look in `docs/`, `.github/`, and nested directories before declaring a file absent.
- **Writing a stale report** — if discovery was run in a prior session, check the file date before reusing it; re-run if the branch has diverged significantly.
- **Over-reporting risks** — a missing `AGENTS.md` is a gap, not a blocker. Keep the Risks section for things that could cause data loss, secret exposure, or broken CI.

## Example Usage

> Starting on `{{REPO_NAME}}` for the first time. Run repo-discovery: scan manifests → find `pnpm` monorepo with three apps, `Node 20`, lint via `eslint`, tests via `vitest`. CI runs on push to `main` with lint + typecheck + test required. `AGENTS.md` missing at root (gap). `.env.example` present. Report written to `.agents/logs/discovery.md`. Recommended next steps: scaffold `AGENTS.md`, run `pnpm install`, confirm `vitest` passes before branching.

## Related Commands

`/gated-orchestration`, `/context-map`

## Maintenance Notes

- Re-run discovery (or the [`../context-mapping/SKILL.md`](../context-mapping/SKILL.md) skill for lighter refresh) whenever the stack, CI, or monorepo structure changes significantly.
- Keep `.agents/logs/discovery.md` dated so a future session can judge whether it is current.
- If the repo adds new manifest types or a new CI provider, extend step 1 and step 3 to cover them.
- This skill feeds into the [initialization workflow](../../../.agents/workflows/initialization.md) — keep the Discovery Report format aligned with what that workflow expects to read.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
