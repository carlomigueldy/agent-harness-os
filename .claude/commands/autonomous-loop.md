---
description: "Meta: classify the work and launch the right bounded loop"
argument-hint: "[loop-type] [target]"
---

# /autonomous-loop

> Classify the work, pick the matching bounded loop, launch it, and return its Loop Report.

## Purpose

Use this when you have a task but are not certain which specific loop to reach for. This meta-command inspects the work, maps it to the correct loop and its iteration cap, and delegates — so you get the right containment and review gate without having to choose manually. It does no implementation itself; it selects once and then returns exactly what the chosen loop returns.

Task/target: **$ARGUMENTS**

## Usage

`/autonomous-loop [loop-type] [target]` — e.g. `/autonomous-loop implement "add input validation to the registration form"` or `/autonomous-loop fix "CI fails on the lint step"`.

If `$ARGUMENTS` is empty, ask for the task or target before proceeding.

## Parameters

- `$1` (optional) — explicit loop type hint: `implement`, `fix`, `test`, `docs`, `review`, or `discover`. If supplied, skip straight to the mapping step and confirm the choice. If omitted, classify the work from context.
- `$2+` (optional) — the task or target description. May also be inferred from context if the caller provides it as a single string.

## Preconditions

- The target task or failing check is clearly stated or can be inferred from the current session state.
- Read [`../../.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md) to know the full loop schema and iteration caps before classifying.
- Repo state is clean or the working change is understood (`git status`).

## Procedure

1. **Classify the work.** Identify which work class the task belongs to, using these definitions:

   | Class | Signals |
   |---|---|
   | `implement` | New feature, enhancement, or multi-file change with acceptance criteria |
   | `fix` | A specific failing check, command, or reproducible bug to make green |
   | `test` | A targeted test suite is failing or needs to be written and run green |
   | `docs` | Documentation is inaccurate, missing, or has broken links |
   | `review` | A completed change needs a 10/10 review-and-fix cycle before shipping |
   | `discover` | Scan history/logs for repeated patterns worth turning into skills or commands |

   If the work spans two classes, choose the dominant one and note the secondary. If genuinely ambiguous and no safe default exists, ask before continuing.

2. **Map to the matching loop and its iteration cap.** Apply this table:

   | Work class | Loop command | Max iterations |
   |---|---|---|
   | `implement` | `/build-loop` | 6 |
   | `fix` | `/fix-loop` | 10 |
   | `test` | `/test-loop` | 6 |
   | `docs` | `/docs-loop` | 4 |
   | `review` | `/review-loop` | 10 |
   | `discover` | `/skill-evolution-loop` | 3 |

   Record the chosen loop and the reason for the choice (one sentence) before launching.

3. **Launch the chosen loop and return its Loop Report.** Invoke the selected loop with the task/target as its argument. Run it to completion (success or cap). Return the Loop Report verbatim as the output of this command — do not summarize or truncate it.

## Stop Conditions

- **Classified and delegated:** the chosen loop ends (success or cap) and its Loop Report is returned. This command's job is then done.
- **Stop and ask:** the work class is genuinely ambiguous with no safe default; or the task description is too underspecified to classify reliably (e.g., no failing check named, no acceptance criteria and none inferable). In that case, ask for the missing information before classifying.
- This command itself has no iteration cap — it selects once, delegates, and returns. The iteration cap is owned by the chosen loop.

## Safety

- Do not start implementation, edits, or destructive actions in this command — that belongs to the delegated loop.
- Confirm before any irreversible or outward-facing action (deletes, force-push, migrations, publishing, sending messages) even if a loop would otherwise proceed.
- Never weaken auth, validation, or rate limits; never commit or echo secrets.
- No AI/LLM attribution in any commit, PR, doc, or comment.

## Output

Emit a brief classification note followed by the full Loop Report from the chosen loop:

```md
## Autonomous Loop — <task>
- Work class: <implement | fix | test | docs | review | discover>
- Chosen loop: /<loop-name>   Reason: <one sentence>
- Max iterations (loop cap): N

---

# Autonomous Loop Report
- Loop: /<name>   Objective: <...>
- Max iterations: N   Used: k
- Work completed: <...>
- Files changed: <...>
- Checks run: <commands + results>
- Review status: Score X/10 — Verdict PASS|REVISE|BLOCK
- Remaining work: <...>
- Handoff: <link to session-handoff.md / issue>
```

## Related

- **Skills:** [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/build-loop`, `/fix-loop`, `/test-loop`, `/docs-loop`, `/review-loop`, `/skill-evolution-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
