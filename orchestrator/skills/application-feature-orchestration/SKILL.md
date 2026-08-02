# Skill: application-feature-orchestration

## Trigger

Se activa cuando el usuario pide explícitamente "implementa esta feature" (o equivalente) para ejecutar el ciclo completo de punta a punta sobre una feature ya descrita en `features/F{num}-{slug}/README.md`.

## Parameters

- `feature_name` (obligatorio): identificador de la feature a orquestar de punta a punta.

## Inputs

- `features/F{num}-{slug}/README.md`.
- `workflows/application-feature.md` (definición de nodos y transiciones).
- `orchestrator.yaml` (fases, permisos, modelos, quality gates).

## Procedure

1. Cargar `workflows/application-feature.md` y verificar si ya existe estado previo en `runtime/state/<feature-id>.yaml` (reanudar si aplica).
2. Ejecutar la fase `intake`: registrar la feature y crear el estado inicial.
3. Ejecutar `feature_analysis` con el agente `feature-analyst` (produce `briefs/<feature-id>/brief.yaml`).
4. Ejecutar `estimation` con `estimator` (produce `briefs/<feature-id>/estimate.yaml`).
5. Ejecutar `planning` con `implementation-planner` (produce `orchestrator/briefs/F{num}-{slug}/PLAN.md` y las carpetas de fase `features/F{num}-{slug}/P{fase}-{slug}/T*.md`, sin tocar `README.md`).
6. Ejecutar `routing` usando `skills/agent-routing/SKILL.md` para asignar implementadores a cada tarea.
7. Ejecutar `implementation`: despachar cada tarea al implementador asignado, usando worktrees cuando corresponda (`skills/parallel-worktrees/SKILL.md`), siguiendo `skills/implementation-execution/SKILL.md`.
8. Ejecutar `review` con `code-reviewer` (`skills/code-review/SKILL.md`).
9. Ejecutar `test` con `unit-test-engineer`, `e2e-test-engineer` y `qa-verifier` (`skills/test-validation/SKILL.md`).
10. Si hay hallazgos bloqueantes en `review` o `test`, volver a `implementation` para el implementador correspondiente (con reintentos según `retry_policy`).
11. Ejecutar `delivery` con `delivery-summarizer` (`skills/delivery-summary/SKILL.md`).

## Expected Result

La feature queda completamente implementada, revisada, probada y documentada con un resumen de entrega en `reports/<feature-id>/`, con el estado del workflow en `completed`.

## Quality Gates

- Todos los quality gates de `orchestrator.yaml -> quality_gates` satisfechos antes de marcar `delivery` como completo.
- Ninguna fase fue saltada.
- Todo hallazgo bloqueante de revisión o pruebas fue resuelto antes de entregar.
