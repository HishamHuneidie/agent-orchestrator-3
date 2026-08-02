<!--
Generado por implementation-planner a partir de briefs/F01-collaborative-lab/brief.yaml
Este PLAN.md es bookkeeping INTERNO del orquestador (vive en orchestrator/briefs/,
no en features/). La carpeta features/F01-collaborative-lab/ solo contiene README.md
(autoría humana) y las carpetas de fase con sus tareas.
-->

# Plan: F01-collaborative-lab

- **feature_id**: `F01-collaborative-lab`
- **Estado**: in_progress <!-- planned | in_progress | completed -->
- **Brief**: `orchestrator/briefs/F01-collaborative-lab/brief.yaml`
- **Fuente**: `features/F01-collaborative-lab/README.md` (autoría humana, no modificado por este plan)

## Alcance

Permitir que varios usuarios colaboren simultáneamente dentro de un mismo lab, viendo los cambios de los demás en tiempo real sin recargar la página.

## Fuera de alcance

- Historial de versiones / undo colaborativo.
- Permisos granulares por usuario dentro de un lab.

## Criterios de aceptación (nivel feature)

- [x] Dos o más usuarios ven los cambios del otro sin recargar la página.
- [ ] Un usuario que se une tarde ve el estado actual completo del lab.
- [ ] La desconexión de un usuario no corrompe el estado del lab para los demás.

## Riesgos

- Conflictos de edición concurrente sobre el mismo recurso dentro del lab.
- Escalabilidad de la conexión en tiempo real con muchos labs activos simultáneamente.

## Estimación total

- Rango: 48–76 horas
- Confianza: medium

## Fases

Cada fase es una carpeta bajo `features/F01-collaborative-lab/`.

### P01-infra — Infraestructura de tiempo real

- **Objetivo**: Establecer el canal de conexión en tiempo real entre clientes de un mismo lab y la sincronización de estado inicial/reconexión.
- **Depende de**: —
- **Tareas**: `T01`, `T02`
- **Worktree**: not-needed

### P02-ui-colaboracion — UI de colaboración

- **Objetivo**: Reflejar en la interfaz los cambios de otros usuarios en tiempo real.
- **Depende de**: `P01-infra`
- **Tareas**: `T01`
- **Worktree**: not-needed

<!-- Repetir un bloque ### P{NN}-{slug} por cada fase adicional -->

## Tareas

Todos los archivos de tarea viven en `features/F01-collaborative-lab/P{fase}-{slug}/`.

| Tarea | Fase | Agente | Repositorio | Depende de | Worktree | Archivo |
|---|---|---|---|---|---|---|
| T01 | P01-infra | backend-engineer | repo-name-1 | — | no | `P01-infra/T01-canal-tiempo-real.md` |
| T02 | P01-infra | backend-engineer | repo-name-1 | T01 | no | `P01-infra/T02-resincronizacion-conexion.md` |
| T01 | P02-ui-colaboracion | frontend-engineer | repo-name-2 | P01-infra | no | `P02-ui-colaboracion/T01-ui-colaboracion.md` |

## Notas de planificación

La fase `P01-infra` se entregó parcialmente: `T01` está completa, pero `T02` (resincronización tras desconexión) quedó con hallazgos bloqueantes en revisión (ver `orchestrator/reports/F01-collaborative-lab/P01-review-report.md`) y debe reintentarse antes de avanzar a `P02-ui-colaboracion`.
