# Decision Log

Running log of every meaningful architectural, tooling, workflow, and orchestration decision made in {{PROJECT_NAME}}.

## Format

Each entry uses this template:

```md
## YYYY-MM-DD — Decision Title

### Context
Why this decision was needed.

### Decision
What was decided.

### Alternatives Considered
Other options and why they were not chosen.

### Consequences
Benefits, tradeoffs, and follow-up work.
```

Log decisions about: architecture, tooling, framework conventions, testing strategy, CI/CD, GitHub issue structure, workflow changes, parallel vs sequential execution, model-tiering strategy, harness file structure, orchestration mode selection, worktree usage, env file handling, skill/superpower usage.

---

<!-- FILL: Append new entries below in reverse-chronological order (newest first). -->

## 2026-06-20 — Reusable, model-tiered subagent roster in `.claude/agents/`

### Context
Dynamic workflows needed reusable, role-typed workers that ship with the template and provision into any repo, with model tiering and a safe self-evolution role.

### Decision
Ship 11 subagent definitions in `.claude/agents/` (one `.md` per role): opus for `planner`/`architect`/`reviewer`/`safety-reviewer`/`integrator`/`skill-smith`; sonnet for `implementer`/`tester`/`debugger`/`docs-writer`; haiku (read-only tools) for `scout`. Each pins the cheapest tier that does the job; `skill-smith` does self-evolution under an approval gate. Document the surface in `.agents/context/subagents.md` (not an in-dir `AGENTS.md`, same namespace rule as commands). `verify-harness.sh` §12 enforces the schema and model tier.

### Alternatives Considered
- Generic single worker agent — rejected: loses role specialization and per-role tiering.
- All-opus roster — rejected: burns opus on mechanical work; tiering is the point.

### Consequences
- Workflows assign work via `agentType` and fan out cheaply, reserving opus for review/architecture/synthesis. The subagent generation workflow stalled mid-run; the roster was completed by hand to the same schema (see orchestration log).

## 2026-06-20 — Reconcile agent-native hardening onto `.agents/`; no parallel `docs/` tree

### Context
A large "agent-native hardening" spec asked for invokable commands, project skills, autonomous loops, recursive context, review gates, and a 12-file `docs/` tree. ~8 of those docs directly overlap existing `.agents/` files.

### Decision
Reconcile every capability onto the existing `.agents/`-centric structure. Add the genuinely missing surfaces — invokable `.claude/commands/` and `.claude/skills/` — and a new `.agents/workflows/autonomous-loops.md`. Do **not** create a parallel `docs/` tree; extend the existing context/workflow docs instead (merge & improve).

### Alternatives Considered
- Literal build of the 12-file `docs/` tree — rejected: two sources of truth, duplicates `.agents/`, violates the harness's own "do not duplicate" rule.
- Minimal (commands+skills only) — rejected: maintainer asked for full coverage of all 8 epics.

### Consequences
- One knowledge hub (`.agents/`) stays canonical; `.claude/` adds executable surfaces that point back into it. Slightly more cross-linking to keep fresh — enforced by `verify-harness.sh`.

## 2026-06-20 — `.claude/commands/` context lives in `.agents/context/slash-commands.md`, not an in-dir `AGENTS.md`

### Context
Claude Code discovers **every** `.md` under `.claude/commands/` as an invokable slash command. A local `AGENTS.md`/`README.md` there would register as a `/AGENTS` / `/README` command and pollute the namespace.

### Decision
Document the command surface (schema + index) in `.agents/context/slash-commands.md`. The `.claude/` surface gets a top-level `.claude/README.md`; the skills dir (whose entries are `<name>/SKILL.md`) safely keeps `.claude/skills/AGENTS.md`.

### Alternatives Considered
- In-dir `AGENTS.md` for commands — rejected: registers as a stray command.

### Consequences
- Command discovery for humans/agents is via `.agents/context/`; the dir holds only real command files. `verify-harness.sh` enforces this (no non-command `.md` in `.claude/commands/`).

## 2026-06-20 — Track this hardening on an in-place epic branch; no tracking issues on the template repo

### Context
Per maintainer guidance, the GitHub-issue-driven workflow in the spec is **instructional harness content** for adopters — not something to execute against the template repo itself. Parallel worker agents also write many distinct files.

### Decision
Work on an in-place epic branch (`harness/agent-native-hardening`) rather than a sibling worktree (the product is repo content; no env/server; a separate worktree only adds path-juggling risk with parallel agents). Track via this repo's own state files (sprint contract, changelog, handover) — the harness's intended system of record. No GitHub tracking issues. Land via a single PR.

### Alternatives Considered
- Sibling worktree — rejected: no isolation benefit here; parallel agents + path juggling add risk.
- GitHub epic + sub-issues — rejected: the issue workflow is template content, not template-repo bookkeeping (supersedes the 2026-06-03 "track via Issues" decision for this effort).

### Consequences
- Clean template (no bookkeeping issues); the build dogfoods the in-repo state system. New labels created earlier are kept as documented taxonomy; removable on request.

## 2026-06-03 — Single source of verification truth: `scripts/verify-harness.sh` + CI

### Context
The harness preaches verification-first but had no automated, reproducible verification for adopters or CI.

### Decision
Add `scripts/verify-harness.sh` as the single verification entry point and have `.github/workflows/ci.yml` run that exact script on push/PR to `main`. Humans and CI run identical checks.

### Alternatives Considered
- Inline checks in the CI YAML — rejected: not runnable locally, drifts from the local workflow.
- Third-party markdown-lint/link-check actions — rejected: heavier and not tailored to harness rules (length limits, no-attribution, structure).

### Consequences
- One place to maintain checks; local == CI. Depends on `python3` (+ `pyyaml`/`ruby`). Adopters extend the script as the project grows.

## 2026-06-03 — Orchestration mode for repo hardening: single agent + reviewer subagent

### Context
The hardening change (README + CI + verify script) needed an execution mode per the orchestration matrix.

### Decision
Single-agent sequential implementation with one independent reviewer subagent for the 10/10 review loop. No agent team or dynamic workflow.

### Alternatives Considered
- Dynamic workflow / agent team — rejected: small, coherent, shared-file change; coordination cost exceeds benefit (the harness's own anti-pattern guidance).

### Consequences
- Low cost, fast. The reviewer caught real false-negative bugs in the verify script (round 1: 8/10 REVISE → round 2: 10/10 PASS), validating the loop.

## 2026-06-03 — Keep template state files reusable; track this repo's work via GitHub Issues

### Context
This repo is both the template and a live project. Filling `feature_list.json` with this repo's work would pollute what adopters copy.

### Decision
Track this repo's own work via GitHub Issues (epic #1, sub-issues #2/#3) and the `.agents/logs/`; keep `feature_list.json`'s example entries as reusable template content. `adoption.md` instructs adopters to reset state files.

### Alternatives Considered
- Add real features to `feature_list.json` — rejected: pollutes the template.

### Consequences
- Template stays clean and copy-ready; live tracking via Issues. Minor expected duplication between Issues and logs.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
