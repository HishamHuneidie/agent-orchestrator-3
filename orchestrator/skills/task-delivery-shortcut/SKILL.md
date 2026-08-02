# Skill: task-delivery-shortcut

## Trigger

Se activa con el atajo `$task F{num}-P{fase}` (p. ej. `$task F01-P01`). Opcionalmente admite `$task F{num}-P{fase}-T{tarea}` para desarrollar una única tarea dentro de la fase.

## Parameters

- `num` (obligatorio): número de la feature; su directorio `features/F{num}-{slug}/` (raíz del monorepo) ya debe existir con al menos una carpeta de fase `P{fase}-{slug}/` generada por `$feat F{num}`.
- `fase` (obligatorio): número de fase a desarrollar (p. ej. `P01`).
- `tarea` (opcional): si se indica, desarrolla únicamente esa tarea en vez de la fase completa.

## Inputs

- `features/F{num}-{slug}/P{fase}-{slug}/T*.md` (tareas de la fase a desarrollar; cada una indica su `Repositorio` de destino bajo `repositories/`).
- `workflows/task-delivery.md`.

## Procedure

1. Parsear el selector `F{num}-P{fase}[-T{tarea}]` con `scripts/resolve-feature-tasks.sh`.
2. Localizar el directorio único `features/F{num}-{slug}/` y, dentro, la carpeta de fase única `P{fase}-{slug}/`. Si no existen, indicar al usuario que ejecute primero `$feat F{num}`.
3. Resolver los archivos de tarea:
   - `F{num}-P{fase}` → todos los archivos `T*.md` dentro de la carpeta de esa fase.
   - `F{num}-P{fase}-T{tarea}` → únicamente ese archivo `T{tarea}-*.md`.
4. Para cada tarea resuelta, usar `skills/agent-routing/SKILL.md` para confirmar/asignar el agente implementador (según lo sugerido en el propio archivo de tarea) y confirmar el repositorio de destino (`repositories/<repo-name>/`, según el campo `Repositorio` de la tarea).
5. Si hay más de una tarea resoluble en paralelo sin dependencias entre sí, usar `skills/parallel-worktrees/SKILL.md` (respetando `parallelism.max_parallel_implementers`).
6. Ejecutar cada tarea siguiendo `skills/implementation-execution/SKILL.md`, escribiendo el código en el repositorio indicado.
7. Tras implementar todas las tareas de la fase, ejecutar `review` (`skills/code-review/SKILL.md`) y `test` (`skills/test-validation/SKILL.md`) para la fase completa.
8. Si la fase queda implementada, revisada y probada sin hallazgos bloqueantes, ejecutar `delivery` (`skills/delivery-summary/SKILL.md`) para esa fase.

## Expected Result

Todas las tareas de la fase `P{fase}` (o la tarea concreta indicada) quedan implementadas en `repositories/<repo-name>/`, revisadas y probadas; si se completó la fase entera, se genera también su resumen de entrega en `orchestrator/reports/F{num}-{slug}/P{fase}-delivery-summary.md`.

## Quality Gates

- El selector se resolvió a al menos una tarea existente en `features/F{num}-{slug}/P{fase}-{slug}/`; si no resuelve a ninguna, se informa al usuario y no se ejecuta nada.
- Ninguna tarea se marca como completada sin pasar por revisión y pruebas.
- Ningún cambio de código se escribió fuera de `repositories/**`.
- El uso de worktrees respeta la política de `orchestrator.yaml -> worktrees`.
