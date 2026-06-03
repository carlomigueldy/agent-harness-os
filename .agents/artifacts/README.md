# Artifacts

Artifacts are concrete evidence produced during verification or demo-driven completion.

They prove that a feature, fix, or workflow change actually works. They are the difference between claiming work is done and demonstrating it.

> **Rule:** A feature cannot be marked `passing` in `feature_list.json` without evidence. Evidence must be real — never fabricated.

---

## What Belongs Here

| Type | Examples |
|---|---|
| Screenshots | UI state, before/after layout, responsive breakpoints, error states |
| GIFs | User interaction flows, animations, loading sequences |
| Short videos | Multi-step demos, complex interactions (keep under 30 s) |
| CLI output | Command results, test run output, build output, migration logs |
| Test reports | HTML test reports, coverage summaries, JUnit XML |
| Browser traces | Playwright traces, Lighthouse reports, network waterfalls |
| Before/after comparisons | Side-by-side layout or behavior diffs |

Do not store large binaries, production data, secrets, or personal information here.

---

## Naming Convention

```
<feature-id>__<description>.<ext>
```

- `feature-id` — matches the `id` field in `../../feature_list.json`
- `__` — double underscore as separator
- `description` — lowercase kebab-case, 3–6 words describing what the artifact shows
- `ext` — file extension matching the artifact type

**Examples:**

```
auth-login__successful-login-flow.png
auth-login__error-invalid-credentials.png
onboarding__welcome-screen-mobile.gif
api-search__results-response-curl.txt
checkout__payment-form-before.png
checkout__payment-form-after.png
dashboard__lighthouse-performance-report.html
contracts__test-run-output.txt
```

For artifacts not tied to a specific feature, use a descriptive prefix:

```
harness__init-sh-baseline-run.txt
ci__build-output-YYYY-MM-DD.txt
```

---

## How Artifacts Are Referenced

Every artifact should be referenced in at least one of:

- **`../../feature_list.json`** — in the `evidence` array for the relevant feature:
  ```json
  "evidence": [
    ".agents/artifacts/auth-login__successful-login-flow.png",
    ".agents/artifacts/auth-login__error-invalid-credentials.png"
  ]
  ```

- **`../logs/verification.md`** — with a description of what the artifact shows and how it was produced.

Artifacts that are not referenced anywhere are orphans. Clean them up or link them.

---

## Size and Storage Guidelines

- **Keep artifacts small.** Screenshots should be compressed where possible. CLI output should be trimmed to relevant sections.
- **GIFs should be short.** Aim for under 5 MB. Use fewer frames or smaller dimensions if needed.
- **Videos should be brief.** Prefer GIFs for short interactions. If video is necessary, keep it under 30 seconds and compress before committing.
- **Large files should not be committed.** If an artifact exceeds ~10 MB, store it externally (e.g. a shared drive, CI artifact store, or issue attachment) and reference the URL in `../logs/verification.md` instead.
- **Do not commit test data or production data.** Blur or anonymize any personal or sensitive information visible in screenshots or recordings.

---

## Keeping the Directory Non-Empty

This directory must not be empty in git.

If no artifacts have been produced yet, keep this `README.md` as the only file. A `.gitkeep` is not required as long as this README is present.

When the first real artifact is added, both this README and the new file should be committed together.

---

## Artifact Lifecycle

1. **Produced** — created during a verification or demo step
2. **Referenced** — linked in `feature_list.json` and/or `../logs/verification.md`
3. **Reviewed** — confirmed by a reviewer during the feedback loop
4. **Retained or pruned** — keep artifacts that remain useful evidence; remove stale ones during harness cleanup

When pruning artifacts, remove their references from `feature_list.json` and `../logs/verification.md` at the same time.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../README.md) and [AGENTS.md](../../AGENTS.md)._
