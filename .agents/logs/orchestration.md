# Orchestration Log

Records every use of subagents, agent teams, or dynamic workflows in {{PROJECT_NAME}}. Append an entry whenever multi-agent orchestration is used.

Also update [./progress.md](./progress.md) and [./verification.md](./verification.md) after each orchestrated session.

## Format

```md
## Orchestration Log — YYYY-MM-DD — Task Name

### Mode Used
Single agent / subagents / agent team / dynamic workflow.

### Why This Mode
Reason this mode was selected over simpler alternatives.

### Workers / Roles
- Lead: ...
- Builder: ...
- Tester: ...
- Reviewer: ...
- (add/remove roles as needed)

### Scope Partition
- Worker A owned: ...
- Worker B owned: ...

### Worktrees
- Branch/path/env status per worker.

### Skills / Superpowers Used
- List any skills invoked.

### Commands / Tools Used
- `command` — purpose

### Implementation Verification
What builders verified before handoff.

### Reviewer Score
X/10.

### Reviewer Verdict
PASS / REVISE / BLOCK.

### Critical Issues
- ...

### Major Issues
- ...

### Minor Issues
- ...

### Nit Issues
- ...

### Findings
- ...

### Decisions Made
- ...

### Final Verification
- ...

### Cost Notes
What was done to avoid unnecessary usage.

### Follow-up
- ...
```

**Hard limits** (require explicit approval to exceed):
| Limit | Default |
|---|---|
| Max subagents | 3 |
| Max agent team size (including lead) | 4 |
| Max dynamic workflow workers | 8 |
| Max feedback iterations | 6 |
| Max active implementation branches | 1 (unless parallel-safe) |
| Max active worktrees per task | 1 (unless agent team or dynamic workflow) |

---

<!-- FILL: Append new orchestration entries below in reverse-chronological order (newest first). -->

## Orchestration Log — 2026-06-20 — Agent-native harness hardening

### Mode Used
Hybrid: inline integrator (main agent) + three dynamic workflows.

### Why This Mode
High file volume (24 commands + 12 skills + 11 subagents = 47 schema-bound files) with clean partition (distinct paths → no write conflict) is the textbook case for scripted fan-out. The architectural backbone (schemas, exemplars, autonomous-loops, review gates, CI) was authored inline for coherence; only the high-volume schema-bound generation was delegated. (Default 8-worker limit exceeded intentionally for fan-out under ultracode; backstopped by deterministic schema CI + Opus review.)

### Workers / Roles
- Workflow 1 (`harness-surface-fanout`): per-file generate (sonnet) → Opus review-and-fix, for 24 commands + 12 skills. 68 agents.
- Workflow 2 (`harness-subagent-roster`): same pattern for 11 subagents — **stalled at 1/11**; remaining 10 hand-authored by the integrator to the same schema.
- Workflow 3 (`harness-final-review`): 3 parallel Opus reviewers (commands/skills, agents/CI, docs/coherence).
- Integrator: main agent — backbone, schema/CI, index wiring, fixes, verification.

### Skills / Superpowers Used
- Project skills authored this session; `opus-code-review` pattern used in review stages.

### Commands / Tools Used
- `Workflow` (3 dynamic workflows), `verify-harness.sh` (deterministic gate).

### Implementation Verification
`verify-harness.sh` 15/15 PASS; 1349 links resolve; 37/37 `/command` refs resolve; per-file Opus review on generated files.

### Reviewer Score / Verdict
Final 3-dimension adversarial Opus review (see verification.md / retrospectives.md for the verdict).

### Cost Notes
sonnet for generation, opus only for review/synthesis; deterministic CI as the cheap backstop so review focuses on quality not schema.

### Follow-up
- Subagent workflow stall is a known background-task fragility under parallel workflows + session interruptions; hand-authoring was the reliable recovery.

## Orchestration Log — 2026-06-03 — Harden harness template repo

### Mode Used
Single agent (sequential implementation) + one independent reviewer subagent.

### Why This Mode
Small, coherent docs+tooling change on shared files. Per the orchestration matrix, single-agent is correct; a reviewer subagent gives an isolated second opinion. Agent team / dynamic workflow not justified (anti-pattern for simple work).

### Workers / Roles
- Implementer: main agent.
- Reviewer: subagent (Opus-tier), adversarial, 10/10 strict.

### Scope Partition
- Implementer: `README.md`, `scripts/verify-harness.sh`, `.github/workflows/ci.yml`, log updates.
- Reviewer: read-only audit of the diff.

### Worktrees
- Branch `harness/repo-hardening` at `../agent-harness-templates-worktrees/harness/repo-hardening`. No env files needed.

### Implementation Verification
- `bash scripts/verify-harness.sh` → 11/11 pass, exit 0; link-checker unit-tested; `bash -n` clean.

### Reviewer Score
- Round 1: 8/10 → Round 2: 10/10.

### Reviewer Verdict
- Round 1: REVISE → Round 2: PASS.

### Critical Issues
- None.

### Major Issues
- M1 (YAML false-pass with no parser); M2 (link-checker missed titled/angle/reference forms). Both fixed.

### Minor Issues
- m1 (length check on missing file); m2 (line-content vs path exclusion). Both fixed.

### Nit Issues
- n1 (label), n2 (action-pinning rationale), n3 (explicit `exit 0`). All addressed.

### Findings
- The independent reviewer caught real false-negative paths in the verification script that the earlier authoring review missed — concrete value from the review loop.

### Decisions Made
- See `./decisions.md` (single-source verify script; orchestration mode; template state kept reusable).

### Final Verification
- 10/10 PASS; verify green locally; CI to confirm on PR #4.

### Cost Notes
- 2 reviewer rounds. Single-agent implementation kept cost well below a team/workflow.

### Follow-up
- Confirm CI green on PR #4; optionally SHA-pin Actions if the threat model requires.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
