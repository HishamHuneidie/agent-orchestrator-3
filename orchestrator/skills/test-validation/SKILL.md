# Skill: test-validation

## Trigger

Se activa en la fase `test` del workflow, para `unit-test-engineer`, `e2e-test-engineer` y `qa-verifier`.

## Parameters

- `task_ref` o `phase_ref` (obligatorio): unidad de trabajo cuyo código se valida.
- `test_types` (opcional): subconjunto de `[unit, e2e, qa]` a ejecutar; por defecto, los tres.

## Inputs

- Código implementado de la tarea/fase.
- `features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-*.md` (criterios de aceptación).
- `templates/test-report.md`, `schemas/test-report.schema.yaml`.
- Hook `hooks/pre-test.md` / `runtime/hooks/pre-test.sh`.

## Procedure

1. Ejecutar el hook `pre-test`.
2. `unit-test-engineer`: cubrir golden path y casos límite de lógica pura/servicios/componentes; ejecutar la suite y capturar resultados reales.
3. `e2e-test-engineer`: identificar flujos críticos de usuario afectados, escribir/ejecutar pruebas e2e contra un entorno real.
4. `qa-verifier`: releer los criterios de aceptación originales y verificar exploratoriamente que se cumplen, incluso más allá de lo cubierto por tests automatizados.
5. Consolidar los tres resultados en `reports/<feature-id>/P{fase}-test-report.md` usando `templates/test-report.md`.
6. Si algún criterio de aceptación no se cumple o algún test falla, marcarlo como bloqueante para que el workflow vuelva a `implementation`.

## Expected Result

Un reporte de pruebas consolidado (unit + e2e + QA) con veredicto explícito por criterio de aceptación, basado en ejecución real, no solo en inspección de código.

## Quality Gates

- Las suites se ejecutaron realmente; el reporte incluye evidencia de ejecución, no solo descripción de lo que "debería" pasar.
- Ningún mock oculta el comportamiento real que el criterio de aceptación pretende validar.
- Todo criterio de aceptación tiene veredicto explícito (cumple/no cumple/parcial).
