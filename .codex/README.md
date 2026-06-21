# Codex Adapter

The `.codex/` directory is the **OpenAI Codex runtime adapter** for the {{PROJECT_NAME}} Agent Harness OS.

## What This Is

The harness core (`.agents/`, `AGENTS.md`, `feature_list.json`, `init.sh`, `scripts/`) is runtime-agnostic. This adapter makes the harness usable in OpenAI Codex by providing thin prompt wrappers that surface the harness's bounded loops using Codex's native `/prompt-name` invocation.

All doctrine lives in `.agents/`. This directory only holds entry points — no content is duplicated.

## How to Use

1. Codex reads `../AGENTS.md` natively as its agent instruction source.
2. `AGENTS.md` (this directory) provides the Codex-specific context map and reading order.
3. Invoke a loop with `/build-loop <task>` — Codex loads `prompts/build-loop.md` and follows its instructions, which point into `.agents/workflows/`.

## Contents

| File | Purpose |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Context map and reading order for Codex sessions |
| [`prompts/build-loop.md`](prompts/build-loop.md) | Bounded implementation loop — example thin prompt |

## Where the Real Doctrine Lives

| Topic | File |
|---|---|
| Universal entry point | [`../AGENTS.md`](../AGENTS.md) |
| Runtime portability model | [`../.agents/context/runtimes.md`](../.agents/context/runtimes.md) |
| Bounded loops (all) | [`../.agents/workflows/autonomous-loops.md`](../.agents/workflows/autonomous-loops.md) |
| Review gate | [`../.agents/workflows/review.md`](../.agents/workflows/review.md) |
| Verification commands | [`../.agents/context/commands.md`](../.agents/context/commands.md) |
| State | [`../feature_list.json`](../feature_list.json) · [`../.agents/logs/`](../.agents/logs/) |

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
