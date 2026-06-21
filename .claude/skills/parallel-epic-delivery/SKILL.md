---
name: parallel-epic-delivery
description: Orchestrate N epics in parallel — one worktree + Workflow lane each (a Sonnet swarm implements, an Opus reviewer drives a 10/10 gate, then PR + PR-diff review), then integration-verify the merged tree and land review-gated PRs on a green trunk. Use when shipping multiple independent epics/features at once with review gates and a protected main.
---

# Skill: parallel-epic-delivery

## Purpose

Deliver several epics concurrently and merge them to `main` without breaking the trunk. Each epic runs in its own git worktree as one lane of a master dynamic Workflow: a Sonnet implementer swarm builds it, an Opus reviewer drives a strict 10/10 acceptance loop (a Sonnet fixer addresses each iteration), then the lane pushes, opens a PR, and an Opus reviewer re-checks the actual PR diff. The orchestrator (main loop) then **independently verifies the integrated tree**, fixes cross-lane gaps, and merges the review-passing PRs in dependency order — re-verifying `main` after each merge.

This is the harness's pattern for "give me N epics in parallel, finish them, review to acceptance, and merge." It trades wall-clock for breadth while keeping a hard green gate and an audit trail. It composes the single-lane loops ([`../autonomous-loop-design/SKILL.md`](../autonomous-loop-design/SKILL.md), [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md)) into a fan-out, and adds the one thing per-lane loops can't give you: verification of the *combined* result before anything lands.

## When to Use

- The user asks to tackle **multiple epics/features in parallel** and take them to merged PRs.
- The work decomposes into **file-disjoint lanes** that meet only through stable seams (shared singletons, interfaces, data contracts).
- A **review-gated** outcome is wanted (10/10 acceptance, adversarial PR review) before anything lands on `main`.
- There is an **executable acceptance signal** (test suite, build/typecheck, lint/harness gates) so agents and reviewers can prove "green" rather than assert it.
- Multi-agent orchestration is in effect — the user has opted into Workflow-scale fan-out across worktrees.

## When Not to Use

- A single epic, a small fix, or tightly-coupled work that cannot be split into disjoint lanes — use one worktree + `/build-loop` + `/review-loop` instead.
- No reliable green gate exists (no tests, no build/lint) — stabilize verification first; parallel agents amplify unverifiable churn.
- The user has **not** opted into multi-agent orchestration — propose it and get approval before spending a large agent fleet (right-sized orchestration is the default).
- Lanes would heavily overlap the same files — the merge cost erases the parallelism benefit; sequence them instead.

## Inputs

- A **green baseline** on `main` (or the integration base): build/typecheck + full test suite + harness/lint gates all passing, with recorded counts.
- A per-epic decomposition with **explicit file-ownership lanes** and the source-of-truth docs per lane (specs / plans / issue docs / acceptance criteria).
- Tooling confirmed available: the build/test binary (`{{TEST_COMMAND}}`), `gh` authenticated, any gitignored test deps or fixtures (`{{TEST_DEP}}`) that worktrees need provisioned.
- Commit identity set to the human author; the no-AI-attribution rule applied to every commit and PR body.

## Outputs

- One review-passing PR per epic, merged to `main` in dependency order, with `main` re-verified green after each merge.
- An evidence-backed delivery summary (per-lane review score/verdict, PR URLs, test deltas, residual/pending items).
- Torn-down worktrees and deleted merged branches (local + remote); a memory/handover note capturing cross-lane lessons.

## Procedure

1. **Recon + green baseline.** Confirm the test/build/lint commands, `gh` auth, branch protection, and the existing issue/spec backlog. Run the **full** gate set on the base and record counts (e.g. `build OK; 358 tests — 306 pass / 52 pending / 0 fail`). If a TDD harness exists, note that pending tests name the exact units each lane must implement — that is the acceptance contract.
2. **Decompose into disjoint lanes.** Assign each epic an explicit **file lane** and the seams it may depend on (shared singletons/interfaces only). Resolve shared-file ownership up front (e.g. who owns the config registry, the event bus, the shared schema). One owner per shared file; others append-only or consume via the seam.
3. **Create worktrees off the green base.** One per epic, following the [worktree protocol](../../../.agents/workflows/worktree-sessions.md): `git worktree add ../{{REPO_NAME}}-worktrees/feat/<epic> -b feat/<epic> <base>`. Set the repo-local commit identity (shared across worktrees). **Provision gitignored test deps** into each worktree (copy, do not commit).
4. **Launch one master Workflow, N parallel lanes.** Each lane is a pipeline run concurrently via `parallel(epics.map(e => () => runEpic(e)))`. Per lane, keep stages sequential within the worktree to avoid file races:
   - **Implement** — Sonnet implementer chunk(s) (`model:'sonnet'`), one coherent slice each, building on existing scaffolding, verifying green and committing before handoff.
   - **Review loop** — Opus reviewer (`model:'opus'`), strict rubric, **≤6 iterations**; gate = score 10 + verdict PASS + independently-confirmed green. A Sonnet fixer addresses every Critical/Major each non-pass iteration.
   - **PR** — push, `gh pr create --base main`; PR body states ACs addressed, tests converted, verification run, and out-of-scope residual. No AI attribution.
   - **PR-diff review** — Opus re-reviews the opened PR diff and body accuracy; one Sonnet fix + re-review if it requests changes.
   - Return structured per-lane results (review score/verdict/green, PR url/number, gatePass).
5. **Integration-verify before touching `main`.** Do **not** trust per-lane green. Trial-merge all lanes into a throwaway detached worktree (`git worktree add --detach /tmp/integ <base>`, discarded after the verify) in the intended dependency order; provision test deps; run the full gate set on the **combined** tree. Cross-lane defects surface only here.
6. **Fix cross-lane gaps on the gate-owning branch.** When a gate fails on the merged tree (e.g. one lane adds a file another lane's gate audits), fix it on the branch that **owns** that gate and **order that branch first** in the merge, so every intermediate `main` state stays green. Re-run the integration verify after the fix.
7. **Merge review-passing PRs in dependency order.** `gh pr merge <n> --merge` (or local-merge + push) in the proven order. Merge **only** gate-passing lanes; leave any that fell short as open PRs with an honest findings report.
8. **Re-verify the real trunk.** Pull `main`, run the full gate set on the actual merged trunk — never ship on the scratch result alone.
9. **Teardown + report.** Remove worktrees, delete merged branches (local + remote — branch delete fails while a worktree holds it, so remove worktrees first). Write the evidence-backed summary and persist cross-lane lessons to memory/handover.

## Checks

- Base and **integrated** trees both pass the full gate set (build/typecheck + tests + harness/lint), with counts recorded; the passing count never drops and failing stays 0.
- Each merged lane carries an Opus **10/10 PASS** on both the work and the PR diff; any lane below the bar stays an open PR, not a merge.
- All lanes trial-merge **conflict-free** in the chosen order before any real merge (proof of lane discipline).
- Cross-lane gate gaps are fixed on the gate-owning branch and that branch merges first; no intermediate `main` state is red.
- Real `main` re-verified green post-merge (not just the scratch integration).
- Every commit authored by the human, Conventional Commits, **zero AI/LLM attribution** anywhere; gitignored test deps and caches never staged.
- Worktrees removed and merged branches deleted; summary + memory note written.

## Common Failure Modes

- **Trusting per-lane green.** Each lane was verified in isolation, so the orchestrator merges without re-checking the combination — and a cross-lane gap (a gate one lane added auditing a file another lane created) ships red. Always run step 5 on the *combined* tree.
- **Overlapping lanes.** Two epics edit the same file; the merge conflicts erase the parallelism win and risk a bad resolution. Resolve file ownership in step 2 before launching any worktree.
- **Merging out of dependency order.** A consumer lane lands before the seam it depends on, leaving an intermediate `main` red. Order the gate-owning / seam-owning branch first.
- **Unbounded review loops.** A lane's Opus loop never reaches 10/10 and spins to the iteration cap. Honor the ≤6 cap; if it can't converge, leave the PR open with findings rather than forcing a merge.
- **Provisioning drift.** A worktree is missing a gitignored test dep, so its "green" is a false pass. Provision (copy, never commit) test deps into every worktree, including the scratch integration one.
- **Staging the wrong thing.** Gitignored test deps, caches, or local env files get committed during a fix. Review every lane's diff before its PR.

## Example Usage

> Goal: "Ship epics A (data layer), B (API), and C (UI) in parallel and merge them."
> Baseline: `{{TEST_COMMAND}}` → `build OK; 120 tests — 120 pass / 0 fail`. Lanes: A owns `data/`, B owns `api/` (depends on A's schema seam), C owns `ui/` (depends on B's client seam). Dependency order A → B → C.
>
> Launch one Workflow, three worktree lanes. A and C finish at 10/10 PASS; B needs two review iterations (Opus flags a missing authz check; Sonnet fixes) then PASSes. Each lane opens a PR; Opus re-reviews each PR diff.
> Integration verify: trial-merge A→B→C into `/tmp/integ` → B's contract test fails against C's new call site → fix on B (the seam owner), re-verify green.
> Merge A, then B, then C; re-verify `main` after each → `124 tests — 124 pass / 0 fail`. Tear down worktrees, delete branches, write the summary. C's adversarial review surfaced a reusable lesson → persisted to memory.

## Related Commands

- `/gated-orchestration` — the approval-gated orchestration entrypoint for fan-out work.
- `/build-loop`, `/review-loop`, `/fix-loop` — the single-lane bounded loops this skill parallelizes across worktrees.
- `/review-pr`, `/review-10x` — the reviewer passes used inside each lane and on the PR diff.
- `/final-handoff` — closing summary + handover after the epics land.
- Skills: [`autonomous-loop-design`](../autonomous-loop-design/SKILL.md), [`opus-code-review`](../opus-code-review/SKILL.md), [`github-issue-planning`](../github-issue-planning/SKILL.md), [`release-readiness`](../release-readiness/SKILL.md). Worktree protocol: [`../../../.agents/workflows/worktree-sessions.md`](../../../.agents/workflows/worktree-sessions.md); dynamic workflows: [`../../../.agents/workflows/dynamic-workflows.md`](../../../.agents/workflows/dynamic-workflows.md).

## Maintenance Notes

Keep the per-lane loop here in step with the single-lane loop caps in [`../../../.agents/workflows/autonomous-loops.md`](../../../.agents/workflows/autonomous-loops.md) and the review gate in [`../opus-code-review/SKILL.md`](../opus-code-review/SKILL.md). Replace `{{TEST_COMMAND}}` / `{{TEST_DEP}}` with the project's real test runner and any vendored test deps during adoption. If the worktree protocol in [`../../../.agents/workflows/worktree-sessions.md`](../../../.agents/workflows/worktree-sessions.md) changes (naming, provisioning, teardown), reconcile steps 3 and 9.

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../../.agents/README.md) and [AGENTS.md](../../../AGENTS.md)._
