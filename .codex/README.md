# Codex Adapter

`.codex/` is the **OpenAI Codex runtime adapter** for the {{PROJECT_NAME}} Agent Harness OS — a thin wrapper around `.agents/`. All doctrine lives in `.agents/`; this directory only provides Codex-native entry points.

Runtime adapters are thin wrappers: no workflow content is duplicated here; everything points back to `.agents/`. See [`.agents/context/runtimes.md`](../.agents/context/runtimes.md) for the full portability model.

| File | Purpose |
|---|---|
| [`prompts/build-loop.md`](prompts/build-loop.md) | Bounded implementation loop — thin prompt wrapper |

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../.agents/README.md) and [AGENTS.md](../AGENTS.md)._
