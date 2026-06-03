# Release Workflow

Finalize, verify, tag, and publish a release safely.

## When to Use

- Shipping a version to production or a public/private registry
- Cutting a tagged release from `{{DEFAULT_BRANCH}}`
- Generating release notes for stakeholders
- Rolling back a bad release

---

## Pre-Release Verification Gate

Do not proceed to tagging until all gates pass.

| Gate | Check | Command |
|---|---|---|
| Tests pass | All test suites green | `{{TEST_CMD}}` |
| Build succeeds | Clean production build | `{{BUILD_CMD}}` |
| Lint clean | No lint errors | `{{LINT_CMD}}` |
| Typecheck clean | No type errors | `{{TYPECHECK_CMD}}` |
| E2E pass (if applicable) | Critical paths working | `{{E2E_CMD}}` |
| No secrets staged | Checked before push | `git status`, `git diff --cached` |
| No LLM attribution | All release assets clean | Manual review |
| Changelog finalized | All entries accurate | See below |
| Feature list current | All shipped features `"passing"` | `feature_list.json` |
| Open Critical/Major issues | None blocking release | GitHub Issues |

If any gate fails, stop and fix before proceeding.

<!-- FILL: Add project-specific gates (e.g., contract deployment dry-run, DB migration check, smoke test against staging) -->

---

## Changelog Finalization

The changelog lives in [../logs/changelog.md](../logs/changelog.md).

Before tagging:

1. Open `../logs/changelog.md`.
2. Add a version header above the most recent date entries:

   ```md
   ## v<MAJOR>.<MINOR>.<PATCH> — YYYY-MM-DD

   ### Added
   - ...

   ### Changed
   - ...

   ### Fixed
   - ...

   ### Refactored
   - ...

   ### Known Issues
   - ...
   ```

3. Ensure all merged features have entries.
4. Remove or condense internal/harness-only entries if not relevant to external consumers.
5. Do not include LLM attribution, internal session notes, or raw agent logs.

---

## Versioning

Use [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

| Change Type | Bump |
|---|---|
| Breaking change | MAJOR |
| New backward-compatible feature | MINOR |
| Bug fix or patch | PATCH |
| Pre-release / alpha | `v0.x.y` or `-alpha.N` suffix |

> TEMPLATE NOTE: If the project uses a different versioning scheme (calendar versioning, build numbers, etc.), document it here.

---

## Tagging and Publishing

```sh
# Confirm you are on the correct branch and it is clean
git status
git log --oneline -5

# Create an annotated tag
git tag -a v<VERSION> -m "Release v<VERSION>"

# Push the tag
git push origin v<VERSION>

# Create a GitHub Release (preferred)
gh release create v<VERSION> \
  --title "v<VERSION>" \
  --notes-file .agents/artifacts/release-notes-v<VERSION>.md

# Or draft first for review
gh release create v<VERSION> --draft \
  --title "v<VERSION>" \
  --notes-file .agents/artifacts/release-notes-v<VERSION>.md
```

<!-- FILL: Add publish commands for the project's specific deployment target: npm publish, docker push, vercel deploy --prod, etc. -->

---

## Release Notes

Generate release notes from the finalized changelog section.

Save to:

```
.agents/artifacts/release-notes-v<VERSION>.md
```

Release notes format:

```md
## v<VERSION> — YYYY-MM-DD

### What's New
- ...

### Bug Fixes
- ...

### Breaking Changes
- ...

### Known Issues
- ...

### Upgrade Notes
<!-- FILL: migration steps, env var changes, dependency updates -->
```

Rules:
- Write for the audience (developers, users, or both — whichever applies).
- Use plain language.
- No LLM attribution.
- No internal session notes.
- No fabricated evidence.

---

## Post-Release Checklist

- [ ] Tag pushed to remote
- [ ] GitHub Release created (or manual deployment confirmed)
- [ ] Release notes published
- [ ] `feature_list.json` statuses correct
- [ ] `changelog.md` finalized for this version
- [ ] `progress.md` updated with release milestone
- [ ] GitHub Issues closed that shipped in this release
- [ ] Stakeholders notified if required
- [ ] Monitoring / alerts checked post-deploy (if applicable)

---

## Rollback

If a release causes critical failures:

1. Identify the last stable tag: `git tag --sort=-creatordate | head -5`
2. Revert the deployment to the previous version using the deployment target's rollback mechanism.
3. Open a `priority: critical` bug issue.
4. Do not delete the broken tag — document what went wrong.
5. Record the failure in [../logs/failures.md](../logs/failures.md).
6. Fix, re-verify, and release a patch.

<!-- FILL: Add project-specific rollback steps for {{DEPLOYMENT_TARGET}} -->

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
