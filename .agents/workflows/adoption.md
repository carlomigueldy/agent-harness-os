# Workflow: Adopting This Harness Template

> One-time "Day 0" guide for dropping this harness into a project. Run this **before** the [initialization workflow](./initialization.md) — initialization assumes the template has already been filled in.

This repo is a **reusable template**. Files contain `{{PLACEHOLDER}}` values and `<!-- FILL: ... -->` / `> TEMPLATE NOTE:` markers that must be specialized for the target project. Adoption is the process of turning the template into a live, project-specific harness.

## When to Use

- You are starting a new project and want the harness from day one.
- You are adding the harness to an existing repo that has none.

If the harness is already adopted (no `{{...}}` placeholders remain in entry files), skip this and go to [initialization.md](./initialization.md).

## Day 0 Checklist

1. **Copy the harness into the target repo.**
   Copy these into the project root: `AGENTS.md`, `CLAUDE.md`, `init.sh`, `feature_list.json`, `claude-progress.md`, `session-handoff.md`, `clean-state-checklist.md`, `evaluator-rubric.md`, `.gitignore` (merge, don't overwrite), `.agents/`, and `.github/`. Do **not** copy `prompt.md` unless you want the harness design spec (it is for harness maintainers, not project agents).

2. **Discover the project.** Inspect the repo and determine: project name/type, primary language, package manager, default branch, deployment target, and the real install/dev/build/lint/typecheck/test/e2e/format commands. Do not assume the stack — confirm it.

3. **Global find-replace the placeholders.** Replace every `{{...}}` token across the copied files with discovered values:

   | Placeholder | Example |
   |---|---|
   | `{{PROJECT_NAME}}` | Acme Web |
   | `{{PROJECT_TYPE}}` | web app / API / CLI / mobile |
   | `{{PRIMARY_LANGUAGE}}` | TypeScript |
   | `{{PACKAGE_MANAGER}}` | pnpm |
   | `{{DEFAULT_BRANCH}}` | main |
   | `{{DEPLOYMENT_TARGET}}` | Vercel / Docker / — |
   | `{{REPO_NAME}}` / `{{GITHUB_OWNER}}` | acme-web / acme |
   | `{{INSTALL_CMD}}` … `{{FORMAT_CMD}}` | the real commands |

4. **Fill the `<!-- FILL -->` sections**, in priority order:
   1. [`../context/commands.md`](../context/commands.md) — the single source of truth for commands.
   2. [`../context/environment.md`](../context/environment.md) — runtimes, env vars, `.env.example`.
   3. [`../context/project-brief.md`](../context/project-brief.md) — what/why/who.
   4. [`../context/architecture.md`](../context/architecture.md) and [`../context/repo-map.md`](../context/repo-map.md).
   5. The remaining context files as you learn the codebase.

5. **Validate the bootstrapper.** Run `bash init.sh` (then `INSTALL=1 bash init.sh` and `VERIFY=1 bash init.sh`). Confirm it detects the stack and that the verification commands actually run.

6. **Seed real state.** Replace the two example features in [`../../feature_list.json`](../../feature_list.json) with real ones. Reset [`../../claude-progress.md`](../../claude-progress.md) and [`../../session-handoff.md`](../../session-handoff.md) to the project's actual starting state.

7. **Set up GitHub.** Create the labels and confirm the issue forms render. See [github-issues.md](./github-issues.md).

8. **Record adoption.** Add an entry to [`../logs/changelog.md`](../logs/changelog.md) and [`../logs/decisions.md`](../logs/decisions.md), then commit with the project's human Git identity — **no AI attribution**.

## Definition of Done (Adoption)

- [ ] No `{{...}}` placeholders remain in `AGENTS.md`, `CLAUDE.md`, or `.agents/context/commands.md`
- [ ] `bash init.sh` and `VERIFY=1 bash init.sh` run cleanly
- [ ] `feature_list.json` holds real features (examples removed)
- [ ] Entry files describe the actual project
- [ ] Adoption logged in changelog/decisions; committed with no AI attribution

Once complete, every future session starts at [initialization.md](./initialization.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
