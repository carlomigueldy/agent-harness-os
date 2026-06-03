# Architecture

System design, patterns, layers, data flow, and key architectural decisions.

## Architecture Style

<!-- FILL: e.g. Monolith / Modular Monolith / Microservices / Serverless / Event-Driven / Layered / Hexagonal / Clean Architecture / DDD -->

> TEMPLATE NOTE: One line is enough here. Expand only if the style has unusual constraints an agent must know.

## Layers / Structure

<!-- FILL: Describe the primary layers or modules and their responsibilities -->

| Layer / Module | Responsibility | Key Files or Paths |
|----------------|---------------|--------------------|
| <!-- FILL --> | <!-- FILL --> | <!-- FILL --> |

> TEMPLATE NOTE: For a frontend app this might be: UI layer, state layer, API client, utilities. For a backend API: transport, use-cases, domain, infrastructure. For contracts: interfaces, implementations, tests.

## Key Components

<!-- FILL: List the most important named components, services, or packages in the system -->

| Component | Role | Location |
|-----------|------|----------|
| <!-- FILL --> | <!-- FILL --> | <!-- FILL --> |

## Data Flow

<!-- FILL: Describe how data moves through the system. Use a short prose description or a simple ASCII/markdown diagram. -->

```
<!-- FILL: e.g.
  User → Browser → API Gateway → Service Layer → Database
                                               → Cache
                                               → Event Bus → Worker
-->
```

> TEMPLATE NOTE: Keep this readable in a terminal. No need for Mermaid unless the project already uses it.

## External Dependencies / Integrations

<!-- FILL: Third-party APIs, services, or infrastructure this system depends on -->

| Dependency | Purpose | Notes |
|------------|---------|-------|
| <!-- FILL --> | <!-- FILL --> | <!-- FILL --> |

## Major Architectural Decisions

All significant architecture decisions are logged in [../logs/decisions.md](../logs/decisions.md).

Key decisions already made:

<!-- FILL: Summarize 2–5 decisions that any future session must know. Link to the decision log for full context. -->

- <!-- FILL: e.g. "Chose X over Y for auth — see decisions.md YYYY-MM-DD" -->

## Known Constraints

<!-- FILL: Performance limits, scaling assumptions, tech debt hotspots, security boundaries an agent must respect -->

- <!-- FILL -->

## What Not to Change Without Review

<!-- FILL: Modules, patterns, or conventions that must not be altered without a design discussion -->

- <!-- FILL -->

## Related Context

- [../logs/decisions.md](../logs/decisions.md) — full decision history
- [conventions.md](./conventions.md) — code style and naming
- [repo-map.md](./repo-map.md) — directory map

---

_Part of the {{PROJECT_NAME}} Agent Harness OS — see the [harness index](../../.agents/README.md) and [AGENTS.md](../../AGENTS.md)._
