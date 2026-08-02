# Skill: delivery-summary

## Trigger

Se activa en la fase `delivery` del workflow, tras completar `review` y `test` con éxito para una fase o feature completa.

## Parameters

- `feature_id` (obligatorio).
- `phase_id` (obligatorio): fase que se está cerrando (p. ej. `P00`).

## Inputs

- `briefs/<feature-id>/brief.yaml`
- `features/F{num}-{slug}/README.md`
- `reports/<feature-id>/P{fase}-review-report.md`
- `reports/<feature-id>/P{fase}-test-report.md`
- `templates/delivery-summary.md`, `schemas/delivery-summary.schema.yaml`.
- Hook `hooks/post-delivery.md` / `runtime/hooks/post-delivery.sh`.

## Procedure

1. Verificar que existen reportes de revisión y pruebas para la fase, y que no tienen hallazgos bloqueantes sin resolver. Si los hay, detener: la entrega no puede cerrarse.
2. Leer brief y plan para recordar el alcance original pedido.
3. Consolidar en `templates/delivery-summary.md`: alcance entregado, decisiones técnicas relevantes, hallazgos de revisión (resueltos y aceptados como deuda técnica si los hay), resultado de pruebas, pendientes explícitos.
4. Guardar en `reports/<feature-id>/P{fase}-delivery-summary.md`.
5. Ejecutar el hook `post-delivery`.
6. Actualizar `runtime/state/<feature-id>.yaml` marcando la fase como `completed`.

## Expected Result

Un resumen de entrega completo y honesto, que cierra formalmente la fase/feature y deja constancia de cualquier deuda técnica aceptada conscientemente.

## Quality Gates

- No se genera el resumen si hay hallazgos bloqueantes sin resolver en revisión o pruebas.
- Ningún pendiente conocido queda fuera del resumen.
- El hook `post-delivery` se ejecutó y no reportó errores.
