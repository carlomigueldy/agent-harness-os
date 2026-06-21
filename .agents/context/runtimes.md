# Runtime Portability Model

The harness is designed so that the **core** is runtime-agnostic and **adapters** are thin wrappers that point back into the core for all doctrine.

## The Principle

| Layer | Files |
|---|---|
| **Core (universal)** | `AGENTS.md` · `.agents/` (doctrine, context, state, logs) · `feature_list.json` · `init.sh` · `scripts/` |
| **Adapter (runtime-specific)** | `.claude/` (Claude Code) · `.codex/` (OpenAI Codex) · any future `.<runtime>/` directory |

Adapters expose harness loops and commands through a runtime's native invocation mechanism. They never duplicate doctrine — they point back into `.agents/`.

## Concept Mapping

| Harness concept | Claude Code | Codex | Generic |
|---|---|---|---|
| Entry instructions | `CLAUDE.md` (adapter) + `AGENTS.md` (universal) | `AGENTS.md` read natively; `CODEX.md` optional | `AGENTS.md` directly |
| Invokable command | `.claude/commands/<n>.md` invoked as `/<name>` | `.codex/prompts/<n>.md` invoked as `/name` | Read `.agents/workflows/` doc directly |
| Skill | `.claude/skills/<n>/SKILL.md` loaded on demand | Referenced procedure (see `.codex/prompts/`) | `.agents/workflows/` doc for the procedure |
| Subagent role | `.claude/agents/<n>.md` model-tiered, auto-routed | Delegate per role using the spec in `.agents/context/subagents.md` | Role spec in `.agents/context/subagents.md` |
| Model tiers | `opus` / `sonnet` / `haiku` | strong / standard / cheap equivalents (e.g. a high-reasoning / mid / small model per provider) | `strong \| standard \| cheap` |
| State & feedback | `feature_list.json` + `.agents/logs/` + `evaluator-rubric.md` — **identical across all runtimes** | Same | Same |

## How Codex Consumes This Harness

1. Codex reads root `AGENTS.md` natively as its agent instruction source.
2. Project-specific invokable prompts live in `.codex/prompts/*.md` and surface as `/name` in Codex. Each prompt is a thin wrapper that points into `.agents/workflows/`.
3. All doctrine (loops, review rubric, stop conditions, state formats) is read from `.agents/` — not duplicated.
4. See the [`.codex/` adapter](../../.codex/README.md) for the adapter overview and [`.codex/prompts/build-loop.md`](../../.codex/prompts/build-loop.md) as a worked example.

## Adapter Contract

To add a new runtime adapter (e.g. `.gemini/`, `.cursor/`):

1. Create a `.<runtime>/` directory at the repo root.
2. Add a `.<runtime>/AGENTS.md` (context map) and a `.<runtime>/README.md` (one-screen overview).
3. Expose each bounded loop and command as a thin native prompt in `.<runtime>/prompts/` (or the runtime's equivalent). Each prompt must:
   - State the task/objective in runtime-neutral language.
   - Reference `.agents/workflows/autonomous-loops.md` and `.agents/workflows/review.md` for iteration caps and stop conditions.
   - NOT duplicate doctrine — point back into `.agents/`.
4. Never copy content from `.agents/` into the adapter. The `.agents/` tree is the single source of truth.
5. Keep `AGENTS.md` authoritative — adapters supplement it, they do not replace it.
6. Run `scripts/verify-harness.sh` after adding; ensure all relative links resolve.

## Activating a Runtime Adapter at Adoption Time

Both adapters (`.claude/` and `.codex/`) ship with the template as tracked directories. The `--runtime` flag on `scripts/provision.sh` **records which runtime is active** for the project and surfaces a matching next-step hint in the provisioner summary — it does not create, scaffold, or remove any adapter directory.

```bash
bash scripts/provision.sh --runtime codex   # record Codex as the active runtime; shows a .codex/ setup hint
bash scripts/provision.sh --runtime claude  # record Claude Code as the active runtime (default)
```

To prune an unneeded adapter (e.g. remove `.codex/` from a Claude-only project), do so manually after provisioning — the adapters are lightweight tracked directories that cost little to keep.

See [`.agents/workflows/adoption.md`](../workflows/adoption.md) for the full adoption procedure.

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
