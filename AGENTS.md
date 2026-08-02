# AGENTS.md

Punto de entrada para cualquier cliente de IA (Codex, Claude Code, ...) que trabaje en este monorepo. Léelo antes de tocar nada.

## Qué es este repositorio

Un monorepo que combina:

- **`orchestrator/`** — el control plane de orquestación de agentes de IA. Contiene el contrato operativo completo (agentes, skills, workflows, hooks, scripts) que rige cómo se analizan, planifican, implementan, revisan y entregan las features.
- **`features/`** — el trabajo en curso: una carpeta por feature (`F{num}-{slug}/`), con su documentación de producto y su plan de fases/tareas.
- **`repositories/`** — el código real de la(s) aplicación(es) sobre las que trabajan los agentes implementadores, una carpeta por repo (`repo-name-1/`, `repo-name-2/`, ...).
- **`docs/`** — documentación funcional y técnica de la aplicación (no del orquestador; esa vive en `orchestrator/docs/`).
- **`scripts/`** — utilidades sh/bash de uso general del monorepo (build, arranque, mantenimiento). Los scripts propios del orquestador viven en `orchestrator/scripts/`.
- **`Makefile`** / **`compose.yaml`** — arranque y orquestación local de los repos bajo `repositories/` (cada uno con su propio `.docker/`).

## Contrato operativo completo

**La guía operativa detallada — atajos, permisos, ciclo de vida de una feature, seguridad — vive en [`orchestrator/AGENTS.md`](./orchestrator/AGENTS.md). Cárgala siempre antes de ejecutar `$feat` o `$task`.**

## Regla rápida: dónde vive cada cosa

| Qué | Dónde |
|---|---|
| Documentación de producto de una feature (autoría humana) | `features/F{num}-{slug}/README.md` |
| Fases de una feature | `features/F{num}-{slug}/P{fase}-{slug}/` (carpetas) |
| Tareas de una fase | `features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-{slug}.md` |
| Código de la aplicación | `repositories/<repo-name>/**` |
| Contratos/config del orquestador | `orchestrator/**` (agents, skills, workflows, schemas, orchestrator.yaml) |
| Briefs, reportes y estado de ejecución (bookkeeping interno) | `orchestrator/briefs/`, `orchestrator/reports/`, `orchestrator/runtime/state/` |

## Atajos

- `$feat F{num}` → analiza `features/F{num}-{slug}/README.md`, genera las carpetas de fase y sus tareas. No implementa código.
- `$task F{num}-P{fase}` → implementa todas las tareas de esa carpeta de fase (código en `repositories/**`, revisión y pruebas incluidas).

Ver `orchestrator/AGENTS.md` para el detalle completo de cada fase, permisos y quality gates.
