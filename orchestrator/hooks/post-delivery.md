# Hook: post-delivery

## Propósito

Se ejecuta después de cerrar la entrega de una fase/feature. Verifica que el resumen de entrega se generó correctamente, archiva la observabilidad de la ejecución, y limpia recursos temporales (worktrees ya integrados) que hayan quedado pendientes de limpieza.

## Cuándo se ejecuta

Inmediatamente después de que `delivery-summarizer` produce `reports/<feature-id>/P*-delivery-summary.md`.

## Inputs

- `reports/<feature-id>/P*-delivery-summary.md`.
- Lista de worktrees asociados a la feature/fase en `runtime/state/<feature-id>.yaml`.

## Outputs

- Confirmación de cierre correcto.
- `runtime/state/<feature-id>.yaml` marcado como `completed` para la fase/feature.
- Worktrees ya integrados limpiados (`scripts/cleanup-worktree.sh`).

## Errores posibles

- El resumen de entrega no existe o no valida contra `schemas/delivery-summary.schema.yaml`.
- Quedan worktrees activos con cambios sin integrar (no deben limpiarse; debe reportarse como pendiente).

## Componente ejecutable correspondiente

`runtime/hooks/post-delivery.sh`
