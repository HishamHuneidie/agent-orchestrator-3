<!--
Template: feature-plan.md
Usado por implementation-planner para generar orchestrator/briefs/{feature_id}/PLAN.md.
Este PLAN.md es bookkeeping INTERNO del orquestador (vive en orchestrator/briefs/,
NO dentro de features/). La carpeta features/{feature_id}/ (raíz del monorepo)
solo contiene README.md (autoría humana, NUNCA generado/sobrescrito por este
template) y las carpetas de fase P{fase}-{slug}/ con sus tareas.
Este archivo es el plan de la feature: fases, tareas y estimaciones. NO contiene
código ni detalles de implementación línea a línea (eso vive en cada tarea).
-->

# Plan: {feature_id}

- **feature_id**: `{feature_id}` <!-- p. ej. F01-collaborative-lab -->
- **Estado**: planned <!-- planned | in_progress | completed -->
- **Brief**: `orchestrator/briefs/{feature_id}/brief.yaml`
- **Fuente**: `features/{feature_id}/README.md` (autoría humana, no modificado por este plan)

## Alcance

{resumen del alcance extraído del brief}

## Fuera de alcance

- {item 1}

## Criterios de aceptación (nivel feature)

- [ ] {criterio 1}
- [ ] {criterio 2}

## Riesgos

- {riesgo 1}

## Estimación total

- Rango: {horas_min}–{horas_max} horas
- Confianza: {low|medium|high}

## Fases

Cada fase es una carpeta bajo `features/{feature_id}/`.

### P01-{slug} — {nombre de la fase}

- **Objetivo**: {qué logra esta fase}
- **Depende de**: —
- **Tareas**: `T01`, `T02`, ...
- **Worktree**: {required|recommended|not-needed}

### P02-{slug} — {nombre de la fase}

- **Objetivo**: {qué logra esta fase}
- **Depende de**: `P01-{slug}`
- **Tareas**: `T01`, ...
- **Worktree**: {required|recommended|not-needed}

<!-- Repetir un bloque ### P{NN}-{slug} por cada fase adicional -->

## Tareas

Todos los archivos de tarea viven en `features/{feature_id}/P{fase}-{slug}/`.

| Tarea | Fase | Agente | Repositorio | Depende de | Worktree | Archivo |
|---|---|---|---|---|---|---|
| T01 | P01-{slug} | backend-engineer | {repo-name} | — | no | `P01-{slug}/T01-{slug}.md` |
| T02 | P01-{slug} | frontend-engineer | {repo-name} | T01 | no | `P01-{slug}/T02-{slug}.md` |

## Notas de planificación

{cualquier decisión de diseño relevante tomada durante la planificación, no obvia desde el código}
