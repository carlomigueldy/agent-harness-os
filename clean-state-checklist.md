# Clean State Checklist — {{PROJECT_NAME}}

Complete every item before ending a session. A session should never leave the next agent guessing what happened.

---

## Git & Worktree Hygiene

- [ ] Git status is understood — no unexpected modified or untracked files
- [ ] Current worktree is known and documented in `claude-progress.md`
- [ ] No accidental or temporary files left behind in the repo or worktree
- [ ] No secrets are staged (`git status` and `git diff --cached` reviewed)
- [ ] Copied env files (`.env`, `.env.local`, etc.) are **not** staged or committed
- [ ] Copied env files are confirmed ignored by `.gitignore`

## State Files Updated

- [ ] `claude-progress.md` updated with current phase, task, blockers, branch, and next best action
- [ ] `.agents/logs/progress.md` updated with latest sprint contract status
- [ ] `feature_list.json` updated — all statuses, evidence, and notes reflect reality
- [ ] `.agents/logs/changelog.md` updated with any changes made this session

## Verification & Evidence

- [ ] Verification was attempted (lint, typecheck, tests, build, or equivalent)
- [ ] Verification result is recorded in `.agents/logs/verification.md`
- [ ] Implementation agents verified their work before handoff where possible
- [ ] If verification could not run, the reason is documented along with remaining risk
- [ ] Demo artifact (screenshot, GIF, CLI output) captured and stored in `.agents/artifacts/` when the change is user-facing

## Review Loop

- [ ] Reviewer score is recorded when a review loop was used
- [ ] Reviewer verdict (`PASS` / `REVISE` / `BLOCK`) is recorded
- [ ] Critical and Major issues from the reviewer have been addressed or logged as follow-up

## Failures & Learnings

- [ ] Any known failures are logged in `.agents/logs/failures.md` with root cause and follow-up
- [ ] Any new learnings (patterns, gotchas, better commands) are appended to `.agents/logs/learnings.md`

## Handover

- [ ] `session-handoff.md` is written with the full handover format (Current State, Completed, In Progress, Next Best Action, etc.)
- [ ] `.agents/logs/handover.md` has been updated with the same handover appended to the archive
- [ ] Next best action is clear and unambiguous
- [ ] Context that would otherwise be re-discovered is captured in "Context to Preserve"

## GitHub Hygiene (when GitHub is available)

- [ ] GitHub Issues updated to reflect current task status
- [ ] Open PRs are referenced in `claude-progress.md`
- [ ] PR description is up to date (no stale auto-close references)

## Orchestration Logging (when multi-agent execution was used)

- [ ] Orchestration mode logged in `.agents/logs/orchestration.md`
- [ ] Worker scope, worktrees, and verification responsibilities documented
- [ ] Reason for choosing the orchestration mode is recorded

## Skill / Superpower Usage (when skills were used)

- [ ] Skills/superpowers used are logged in the handover and in `.agents/logs/progress.md`
- [ ] Any new skill proposals added to `.agents/proposals/` if a repeated pattern was noticed
