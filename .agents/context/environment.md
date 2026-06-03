# Environment

Runtime versions, install steps, environment variables, local setup, Docker/devcontainer, database setup, and safe env-file handling for worktrees.

## Runtime Versions

<!-- FILL: List every runtime with its required version. Use exact versions or minimum version where appropriate. -->

| Runtime | Required Version | How to Install |
|---------|-----------------|---------------|
| <!-- FILL: e.g. Node.js --> | <!-- FILL: e.g. 20.x LTS --> | <!-- FILL: e.g. nvm, asdf, fnm --> |
| <!-- FILL: e.g. Python --> | <!-- FILL: e.g. 3.12+ --> | <!-- FILL: e.g. pyenv --> |
| <!-- FILL: e.g. Go --> | <!-- FILL: e.g. 1.22+ --> | <!-- FILL: e.g. goenv or brew --> |
| {{PACKAGE_MANAGER}} | <!-- FILL: version --> | <!-- FILL --> |

> TEMPLATE NOTE: If the project uses `.nvmrc`, `.tool-versions`, or `pyproject.toml` to pin versions, reference those files here.

## Install Steps

```bash
# 1. Clone the repository
git clone https://github.com/{{GITHUB_OWNER}}/{{REPO_NAME}}.git
cd {{REPO_NAME}}

# 2. Install runtime (if using version manager)
# <!-- FILL: e.g. nvm use / asdf install -->

# 3. Install dependencies
{{INSTALL_CMD}}

# 4. Copy environment file
cp .env.example .env
# Then fill in real values — see Environment Variables section below

# 5. <!-- FILL: any additional setup (e.g. database init, contract compile) -->

# 6. Start dev server
{{DEV_CMD}}
```

> TEMPLATE NOTE: Update these steps to match the actual project setup sequence discovered during harness initialization.

## Environment Variables

All required environment variables. Never commit real values.

| Variable | Required | Description | Example Value |
|----------|----------|-------------|---------------|
| <!-- FILL: e.g. DATABASE_URL --> | Yes | <!-- FILL: e.g. PostgreSQL connection string --> | `postgresql://user:changeme@localhost:5432/mydb` |
| <!-- FILL: e.g. API_SECRET_KEY --> | Yes | <!-- FILL: e.g. Server-side signing secret --> | `sk-xxxxxxxxxxxxxxxxxxxxxxxx` |
| <!-- FILL: e.g. NEXT_PUBLIC_API_URL --> | Yes | <!-- FILL: e.g. Public API base URL --> | `http://localhost:3001` |
| <!-- FILL: e.g. NODE_ENV --> | No | <!-- FILL --> | `development` |

> TEMPLATE NOTE: Add every variable the app reads. Use obviously-fake example values like `sk-xxxxxxxx` or `changeme`. Never use real secrets here.

## .env.example Pattern

```dotenv
# === Database ===
DATABASE_URL=postgresql://user:changeme@localhost:5432/{{PROJECT_NAME}}_dev

# === Auth ===
# <!-- FILL: e.g. AUTH_SECRET -->
AUTH_SECRET=changeme-replace-with-64-char-random-string

# === External APIs ===
# <!-- FILL: e.g. STRIPE_SECRET_KEY -->
STRIPE_SECRET_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx

# === App ===
NODE_ENV=development
PORT=3000
```

> TEMPLATE NOTE: Keep `.env.example` committed to the repo. Keep `.env` in `.gitignore`. An agent must be able to run `cp .env.example .env` and fill in real values.

## Local Setup

<!-- FILL: Any setup steps beyond install + env — e.g. browser extension install, local proxy, hosts file entry, VS Code extensions -->

- <!-- FILL -->

## Docker / Devcontainer

<!-- FILL: If the project uses Docker for dev or CI, document how to start it. If no Docker, remove this section. -->

```bash
# Start all services (database, cache, etc.)
# <!-- FILL: e.g. docker compose up -d -->

# Stop services
# <!-- FILL: e.g. docker compose down -->
```

> TEMPLATE NOTE: Note any required images or build steps. Document which services must be running before `{{DEV_CMD}}`.

## Database Setup

<!-- FILL: If the project has a database, document initialization, migrations, and seed steps. Remove if not applicable. -->

```bash
# Create local database
# <!-- FILL: e.g. createdb mydb_dev OR docker compose exec db psql ... -->

# Run migrations
# <!-- FILL: see commands.md for exact command -->

# Seed development data (safe in dev only)
# <!-- FILL: see commands.md for exact command -->
```

## Contract / Blockchain Setup

<!-- FILL: If the project has smart contracts, document compile, local node, and deploy steps. Remove if not applicable. -->

## Deployment Requirements

<!-- FILL: What is needed to deploy? CI secrets, cloud credentials, deployment targets? -->

- **Deployment target:** `{{DEPLOYMENT_TARGET}}`
- <!-- FILL: e.g. Requires VERCEL_TOKEN in CI -->
- <!-- FILL: e.g. Production deploy requires human approval -->

## Copying Env Files into a Worktree

When creating a new git worktree, copy required env files safely.

**Never stage or commit copied env files.**

### Steps

```bash
# 1. Identify env files in the main worktree
#    Look for: .env .env.local .env.development .env.test
#    and any app-specific envs: apps/*/.env packages/*/.env

# 2. Copy to the session worktree at the same relative path
#    Example (adjust paths):
cp /path/to/main-worktree/.env /path/to/session-worktree/.env

# 3. Verify the file is git-ignored in the worktree
git -C /path/to/session-worktree check-ignore -v .env

# 4. Confirm nothing is staged
git -C /path/to/session-worktree status
```

### Rules

- Copy env files **only** for local development and verification.
- **Never commit** copied env files.
- Ensure all env file names are listed in `.gitignore`.
- **Do not print secret values** in logs, terminal output, or harness files.
- Do not overwrite an existing env file in the worktree without checking first.
- If env files are missing or inaccessible, document what is missing and continue with safe non-secret verification where possible.

### If Env Files Are Missing

Log the gap in `../../session-handoff.md` or `../logs/progress.md`:

```md
### Env Files
Missing: .env — required for database connection. Proceeding with unit tests only.
```

See [worktrees.md](./worktrees.md) for the full worktree creation workflow.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
