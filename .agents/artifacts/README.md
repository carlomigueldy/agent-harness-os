# Artifacts

Concrete evidence produced during verification or demo-driven completion. A feature cannot be marked `passing` in `feature_list.json` without real evidence — never fabricated.

## What Belongs Here

Screenshots, GIFs, short videos (under 30 s), CLI output, test reports, browser traces, and before/after comparisons. Do not store large binaries (>10 MB — use external storage and reference the URL), production data, secrets, or personal information.

## Naming Convention

```
<feature-id>__<description>.<ext>
```

`feature-id` matches the `id` in `../../feature_list.json`. Use `harness__` or `ci__` prefix for non-feature artifacts.

## How Artifacts Are Referenced

Every artifact must appear in at least one of:

- `../../feature_list.json` — in the `"evidence"` array for the relevant feature.
- `../logs/verification.md` — with a description of what it shows and how it was produced.

Unreferenced artifacts are orphans; clean them up or link them.

## Lifecycle

Produced → Referenced → Reviewed → Retained or pruned. When pruning, remove references from `feature_list.json` and `../logs/verification.md` at the same time.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
