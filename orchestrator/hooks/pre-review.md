# Hook: pre-review

## Propósito

Se ejecuta antes de iniciar la revisión de código de una tarea/fase. Verifica que hay efectivamente código implementado que revisar y que el entorno de revisión está en un estado consistente (sin cambios sin commitear de otras tareas mezclados).

## Cuándo se ejecuta

Justo antes de despachar a `code-reviewer` para la fase `review`.

## Inputs

- Referencia a la tarea/fase (`task_ref`/`phase_ref`).
- Estado del árbol de trabajo (worktree o rama principal) relevante.

## Outputs

- Confirmación de que la revisión puede proceder, o un bloqueo si no hay cambios que revisar o el árbol está en un estado inconsistente.

## Errores posibles

- No hay cambios de código asociados a la tarea/fase indicada.
- El árbol de trabajo mezcla cambios de múltiples tareas no relacionadas (debe señalarse como problema de proceso antes de revisar).
- El worktree de la tarea no existe o fue eliminado prematuramente.

## Componente ejecutable correspondiente

`runtime/hooks/pre-review.sh`
