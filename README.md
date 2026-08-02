# agent-orchestrator-3

Monorepo que combina un **sistema de orquestación de agentes de IA para desarrollo de software** (`orchestrator/`) con el código real de la(s) aplicación(es) que ese sistema construye (`repositories/`).

## En una frase

Documentas una feature en lenguaje natural → un cliente de IA (Claude Code, Codex...) la analiza, la planifica en fases/tareas, y luego implementa cada fase (código + revisión + pruebas) siguiendo un contrato explícito de agentes, permisos y calidad — todo versionado como texto plano en este repo.

## Piezas del monorepo

| Carpeta | Qué es |
|---|---|
| `orchestrator/` | El **control plane**: contratos de comportamiento de 12 agentes (analista, estimador, planificador, implementadores, revisor, testers, resumen de entrega), las skills/workflows/hooks que los orquestan, los schemas que validan lo que producen, y los scripts que verifican todo. No es una app desplegable ni tiene un runtime propio — el cliente de IA activo *es* el runtime, guiado por `AGENTS.md`. |
| `features/` | Trabajo en curso. Una carpeta por feature (`F{num}-{slug}/`) con `README.md` (alcance, autoría humana) y una subcarpeta por fase (`P{fase}-{slug}/`) con sus tareas (`T{tarea}-{slug}.md`). |
| `repositories/` | El código real de la aplicación, uno por repo (`repo-name-1/`, `repo-name-2/`, cada uno con su `.docker/`). Aquí es donde los agentes implementadores escriben código — nunca en `orchestrator/` ni en `features/`. |
| `docs/` | Documentación funcional/técnica de la aplicación (arquitectura de producto, decisiones de stack). Distinta de `orchestrator/docs/`, que documenta el propio orquestador. |
| `scripts/` | Utilidades sh/bash de uso general del monorepo (setup, build). Distinta de `orchestrator/scripts/`, que son los scripts propios del control plane. |
| `Makefile` / `compose.yaml` | Arranque local de los repos bajo `repositories/` vía Docker Compose. |
| `AGENTS.md` / `CLAUDE.md` | Punto de entrada para cualquier cliente de IA que trabaje en este repo; remiten al contrato operativo completo en `orchestrator/AGENTS.md`. |

## Cómo se usa (atajos)

- `$feat F{num}` — analiza `features/F{num}-{slug}/README.md` (ya escrito por ti) y genera el plan: carpetas de fase con sus tareas. **No escribe código.**
- `$task F{num}-P{fase}` — implementa todas las tareas de esa fase en el `repositories/<repo-name>/` correspondiente, con revisión de código y pruebas incluidas.
- `implementa esta feature` — ejecuta el ciclo completo de punta a punta (análisis → estimación → planificación → implementación → revisión → pruebas → entrega).

## Filosofía de diseño

- **Markdown** para contratos de comportamiento (agentes, skills, workflows), **YAML** para configuración/datos versionados, **Bash** para validación — todo auditable en Git, sin infraestructura adicional.
- **Mínimo privilegio**: cada agente tiene explícito qué puede leer/escribir; `.git/`, `.codex/` y `.claude/` están totalmente prohibidos, y un escáner de secretos falla cerrado ante cualquier violación.
- **Separación estricta entre plan y código**: `$feat` nunca implementa; `$task` nunca planifica. El `README.md` de cada feature es siempre autoría humana — ningún agente lo sobrescribe.

## Más detalle

- [`orchestrator/README.md`](./orchestrator/README.md) — uso rápido y flujo principal del control plane.
- [`orchestrator/AGENTS.md`](./orchestrator/AGENTS.md) — contrato operativo completo (permisos, ciclo de vida, quality gates).
- [`orchestrator/docs/`](./orchestrator/docs/) — arquitectura, seguridad, worktrees, observabilidad.
- [`ORCHESTRATOR-DOCUMENTATION.md`](./ORCHESTRATOR-DOCUMENTATION.md) — documento de referencia original del diseño del orquestador.
