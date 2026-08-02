# Skill: code-review

## Trigger

Se activa cuando `code-reviewer` necesita revisar el código implementado de una tarea o fase, antes de que avance a `test`/`delivery`.

## Parameters

- `task_ref` o `phase_ref` (obligatorio): unidad de trabajo cuyo código se revisa.

## Inputs

- Diff/código modificado de la tarea/fase.
- `features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-*.md` (criterios de aceptación).
- `templates/review-report.md`, `schemas/review-report.schema.yaml`.
- Hook `hooks/pre-review.md` / `runtime/hooks/pre-review.sh`.

## Procedure

1. Ejecutar el hook `pre-review` (verifica que hay algo que revisar y que el entorno está en estado consistente).
2. Leer los criterios de aceptación de la tarea/fase.
3. Leer el código modificado completo (no solo un resumen del diff).
4. Contrastar cada criterio de aceptación contra el código real.
5. Buscar activamente: problemas de seguridad, secretos, sobre-ingeniería, manejo de errores innecesario o faltante, inconsistencias con convenciones del repo.
6. Verificar cada hallazgo releyendo el código antes de incluirlo en el reporte (evitar falsos positivos).
7. Clasificar hallazgos por severidad: bloqueante, importante, menor.
8. Redactar el reporte con `templates/review-report.md` y guardarlo en `reports/<feature-id>/P{fase}-review-report.md`.

## Expected Result

Un reporte de revisión completo, con hallazgos verificados y priorizados, que determina si la tarea/fase puede avanzar a `test` o debe volver a `implementation`.

## Quality Gates

- Todo hallazgo reportado fue verificado releyendo el código real.
- Todo criterio de aceptación fue contrastado explícitamente.
- Los hallazgos de seguridad (si existen) están marcados como bloqueantes y aparecen primero.
