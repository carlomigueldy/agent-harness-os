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
