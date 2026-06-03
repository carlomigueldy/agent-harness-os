# Conventions

Coding conventions, naming rules, commit format, branch naming, PR conventions, and file-structure rules.

## Coding Style

<!-- FILL: Language-specific style guide or linter config. e.g. "ESLint + Prettier, config at .eslintrc.cjs" or "Ruff for Python, config in pyproject.toml" -->

> TEMPLATE NOTE: Point to the config file rather than restating all rules here. Only call out non-obvious conventions that agents commonly miss.

| Rule | Description |
|------|-------------|
| <!-- FILL: e.g. Line length --> | <!-- FILL: e.g. 100 chars max --> |
| <!-- FILL: e.g. Quotes --> | <!-- FILL: e.g. Single quotes for JS/TS --> |
| <!-- FILL: e.g. Trailing commas --> | <!-- FILL: e.g. Required in multi-line expressions --> |

## Naming Conventions

<!-- FILL: Variables, functions, classes, files, database tables, API endpoints -->

| Scope | Convention | Example |
|-------|-----------|---------|
| Files | <!-- FILL: e.g. kebab-case --> | <!-- FILL: e.g. user-profile.ts --> |
| Components | <!-- FILL: e.g. PascalCase --> | <!-- FILL: e.g. UserProfile.tsx --> |
| Functions | <!-- FILL: e.g. camelCase --> | <!-- FILL: e.g. getUserById() --> |
| Types/Interfaces | <!-- FILL: e.g. PascalCase, no "I" prefix --> | <!-- FILL: e.g. UserProfile --> |
| Database tables | <!-- FILL: e.g. snake_case, plural --> | <!-- FILL: e.g. user_profiles --> |
| Env vars | <!-- FILL: e.g. SCREAMING_SNAKE_CASE --> | <!-- FILL: e.g. DATABASE_URL --> |

## Import Rules

<!-- FILL: Import ordering, path alias usage, absolute vs relative, barrel files allowed/forbidden -->

- <!-- FILL: e.g. "Use path aliases (@/) over relative paths for cross-module imports" -->
- <!-- FILL: e.g. "No barrel index.ts files in feature modules" -->

## Commit Conventions

Commits in this project follow this format:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:** `feat` | `fix` | `docs` | `chore` | `refactor` | `test` | `perf` | `ci` | `harness`

**Rules:**
- Use the imperative mood: "add feature" not "added feature"
- Keep the subject line under 72 characters
- Reference GitHub issues with `Closes #N`, `Fixes #N`, or `Resolves #N` in the footer
- **Human author only.** Do not add AI/LLM co-author lines. The commit author is the human developer.
- No `Co-authored-by: Claude`, `Co-authored-by: ChatGPT`, or any equivalent AI attribution.

**Examples:**
```
feat(auth): add OAuth2 login with GitHub provider

Closes #42
```
```
fix(api): handle null response from payment gateway

Fixes #87
```

## Branch Naming

| Prefix | Use for |
|--------|---------|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `docs/` | Documentation-only changes |
| `chore/` | Tooling, dependencies, config |
| `refactor/` | Code restructuring without behavior change |
| `test/` | Adding or fixing tests |
| `harness/` | Agent harness improvements |

Keep branch names short and descriptive: `feat/user-auth`, not `feat/add-user-authentication-feature-for-login`.

Default branch: `{{DEFAULT_BRANCH}}`

## PR Conventions

- PR title must match the commit convention subject format.
- Link to the relevant GitHub issue.
- Use closing keywords: `Closes #N`, `Fixes #N`, or `Resolves #N`.
- Every non-trivial PR should have: a summary, test plan, and verification evidence.
- PRs must not contain staged `.env` files or secrets.
- See `.github/pull_request_template.md` for the standard template.

## File Structure Rules

<!-- FILL: Where do new files go? Are there conventions for feature folders, co-location of tests, shared utilities? -->

- <!-- FILL: e.g. "Tests co-located with source files: user.service.test.ts next to user.service.ts" -->
- <!-- FILL: e.g. "Shared utilities live in src/lib/, not scattered in feature folders" -->
- <!-- FILL: e.g. "Each feature module is self-contained: components, hooks, types, and tests in the same directory" -->

> TEMPLATE NOTE: Add project-specific rules discovered during harness initialization.

## What Requires Review

<!-- FILL: Changes that must not be merged without human or Evaluator review -->

- <!-- FILL: e.g. Changes to auth, payments, migrations, public API contracts -->

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
