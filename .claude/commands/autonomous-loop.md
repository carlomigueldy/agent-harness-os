---
description: "Meta: classify the work and launch the right bounded loop"
argument-hint: "[loop-type] [target]"
---

# /autonomous-loop

> Classify the work, pick the matching bounded loop, launch it, and return its Loop Report.

## Purpose

Use this when you have a task but are not certain which specific loop to reach for. Inspects the work, maps it to the correct loop and its iteration cap, and delegates — returning exactly what the chosen loop returns. Does no implementation itself.

Task/target: **$ARGUMENTS**

## Usage

`/autonomous-loop [loop-type] [target]` — e.g. `/autonomous-loop implement "add input validation"` or `/autonomous-loop fix "CI fails on the lint step"`.

Optionally supply `$1` as an explicit loop-type hint (`implement`, `fix`, `test`, `docs`, `review`, `discover`). If `$ARGUMENTS` is empty, ask before proceeding.

## Preconditions

- The target task or failing check is clearly stated or inferable from context.
- Repo state is clean or the working change is understood (`git status`).

## Procedure

Classify the task into `implement / fix / test / docs / review / discover`, map to the matching loop, and delegate. Full work-class map and caps: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Stop Conditions

This command selects once and delegates; stop conditions are owned by the chosen loop. See [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Safety

Do not start implementation or destructive actions here — delegate to the chosen loop. Confirm before irreversible or outward-facing actions even if the loop would otherwise proceed.

## Output

Emits a brief classification note then returns the full Loop Report from the chosen loop verbatim. Loop-type mapping, caps, stop conditions, safety rules, and Loop Report format: [`.agents/workflows/autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md).

## Related

- **Skills:** [`autonomous-loop-design`](../../.claude/skills/autonomous-loop-design/SKILL.md)
- **Workflows:** [`autonomous-loops.md`](../../.agents/workflows/autonomous-loops.md)
- **Commands:** `/build-loop`, `/fix-loop`, `/test-loop`, `/docs-loop`, `/review-loop`, `/skill-evolution-loop`

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
