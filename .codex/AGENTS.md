# {{PROJECT_NAME}} — Codex Adapter

> This is the context map for the `.codex/` adapter directory. Read `../AGENTS.md` first, then this file.

## What This Directory Is

`.codex/` is the **OpenAI Codex runtime adapter** for the {{PROJECT_NAME}} Agent Harness OS. It is a thin layer — all doctrine lives in `.agents/`; this directory only provides Codex-native entry points that point back into it. No workflow content is duplicated here.

## Reading Order (Codex sessions)

1. [`../AGENTS.md`](../AGENTS.md) — universal entry point, hard constraints, definition of done
2. This file — Codex adapter context map
3. [`../claude-progress.md`](../claude-progress.md) — current state snapshot
4. [`../.agents/logs/progress.md`](../.agents/logs/progress.md) — sprint log
5. [`../session-handoff.md`](../session-handoff.md) — last handover
6. [`../feature_list.json`](../feature_list.json) — machine-readable feature status

## Contents

| Path | Purpose |
|---|---|
| [`README.md`](README.md) | One-screen adapter overview |
| [`prompts/build-loop.md`](prompts/build-loop.md) | Example thin prompt: bounded implementation loop (mirrors `/build-loop`) |

## How Prompts Work

Each file in `prompts/` is a thin, runtime-neutral prompt. It states the task/objective and references the relevant `.agents/workflows/` doc for the full procedure. To invoke in Codex: `/build-loop <task>` (or the Codex equivalent for your version).

## Portability Model

For the full mapping of harness concepts across Claude Code, Codex, and generic runtimes, see [`.agents/context/runtimes.md`](../.agents/context/runtimes.md).

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
