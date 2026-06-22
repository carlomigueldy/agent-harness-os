# Evaluator Rubric — {{PROJECT_NAME}}

Use this rubric in every review loop. Score each dimension from 1–10, then compute the overall verdict.

---

## Scoring Dimensions

| Dimension | Weight / Notes | Score (1–10) |
|---|---|---|
| **Correctness** | Does the implementation do what the acceptance criteria specify? Zero regressions? | |
| **Verification quality** | Were lint, typecheck, tests, and build run? Is evidence present or failure justified? | |
| **Architecture fit** | Does the change fit existing patterns? No unnecessary abstractions or violations? | |
| **Simplicity** | Is the solution as simple as it can be without sacrificing correctness? | |
| **Maintainability** | Is the code readable, well-named, and easy to extend or modify safely? | |
| **Test coverage** | Are new behaviors covered by tests? Are edge cases handled? | |
| **UX / demo quality** | For user-facing changes: is the UX correct and is a demo artifact present? | |
| **Frontend design quality** | For UI changes: responsive, accessible, consistent with design system? (N/A if not applicable) | |
| **Accessibility** | Basic a11y met (labels, contrast, keyboard nav)? (N/A if not applicable) | |
| **Performance impact** | No obvious regressions in load time, rendering, or query cost? | |
| **Security / privacy risk** | No new attack surfaces, secrets exposed, or insecure patterns introduced? | |
| **Documentation quality** | Are inline comments, context files, and handover docs updated where needed? | |
| **Handover quality** | Is `session-handoff.md` complete? Is `claude-progress.md` up to date? | |
| **Worktree hygiene** | Was a worktree used appropriately? No env files staged? Branch named correctly? | |
| **GitHub issue / PR hygiene** | Issues linked? PR description accurate? Auto-close keywords used correctly? | |
| **No LLM attribution** | Zero AI/LLM attribution in commits, PRs, docs, comments, or changelogs? | |
| **Secret safety** | No secrets staged, committed, or printed in logs? | |

---

## Severity Definitions

| Severity | Definition | Blocks PASS? |
|---|---|---|
| **Critical** | Correctness failure, security hole, data loss, broken contract, or regression that ships to users | Yes |
| **Major** | Significant functional gap, missing test coverage for new behavior, broken link in critical path, or missing evidence | Yes |
| **Minor** | Readability issue, non-critical missing doc, suboptimal naming, incomplete handover section | No (REVISE preferred) |
| **Nit** | Style, formatting, cosmetic — optional polish only | No |

---

## Verdict Rules

```
Score 10/10  +  Critical issues: 0  +  Major issues: 0  +  Evidence present  →  PASS
Score  7–9   or  Minor/Nit issues only                                         →  REVISE (or PASS if explicitly accepted)
Score  1–6   or  any Critical/Major issue                                       →  BLOCK or REVISE
```

**Strict mode (autonomous loops):** PASS requires exactly 10/10. Do not give PASS for 9/10 in an autonomous feedback loop.

**Maximum feedback iterations:** 6. If iteration 6 is reached and Critical/Major issues remain, do not ship — document and create follow-up issues.

---

## Review Result Block

Copy this block and fill it in for every completed review.

```
## Review Result — YYYY-MM-DD — [Task Name]

### Score
X / 10

### Verdict
PASS | REVISE | BLOCK

### Critical Issues (must fix before PASS)
- (none) | - description

### Major Issues (must fix before PASS)
- (none) | - description

### Minor Issues (fix preferred but not blocking)
- (none) | - description

### Nit Issues (optional polish)
- (none) | - description

### Evidence Checked
- [ ] Lint output
- [ ] Typecheck output
- [ ] Test results
- [ ] Build output
- [ ] Screenshot / GIF / demo artifact
- [ ] No secrets staged (git diff --cached reviewed)
- [ ] No LLM attribution (grep reviewed)

### Required Follow-up
- (none) | - issue #N or task description
```
