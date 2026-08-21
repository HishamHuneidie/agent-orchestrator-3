# Skill: task-delivery-shortcut

## Trigger

Se activa con el atajo `$task F{num}-P{fase}` (p. ej. `$task F01-P01`). También admite `$task F{num}` (p. ej. `$task F01`) para desarrollar todas las fases planificadas de la feature. Opcionalmente admite `$task F{num}-P{fase}-T{tarea}` para desarrollar una única tarea dentro de la fase.

## Parameters

- `num` (obligatorio): número de la feature; su directorio `features/F{num}-{slug}/` (raíz del monorepo) ya debe existir con al menos una carpeta de fase `P{fase}-{slug}/` generada por `$feat F{num}`.
- `fase` (opcional): número de fase a desarrollar (p. ej. `P01`). Si se omite, se desarrollan todas las fases `P*` de la feature.
- `tarea` (opcional): si se indica, desarrolla únicamente esa tarea en vez de la fase completa.

## Inputs

- `features/F{num}-{slug}/P{fase}-{slug}/T*.md` para una fase concreta, o `features/F{num}-{slug}/P*/T*.md` para la feature completa (cada tarea indica su `Repositorio` de destino bajo `repositories/`).
- `workflows/task-delivery.md`.

## Procedure

1. Parsear el selector `F{num}[-P{fase}[-T{tarea}]]` con `scripts/resolve-feature-tasks.sh`.
2. Localizar el directorio único `features/F{num}-{slug}/` y, si se indicó `P{fase}`, la carpeta de fase única `P{fase}-{slug}/`. Si no existen, indicar al usuario que ejecute primero `$feat F{num}`.
3. Resolver los archivos de tarea:
   - `F{num}` → todos los archivos `P*/T*.md` de la feature, recorriendo las fases en orden numérico por defecto.
   - `F{num}-P{fase}` → todos los archivos `T*.md` dentro de la carpeta de esa fase.
   - `F{num}-P{fase}-T{tarea}` → únicamente ese archivo `T{tarea}-*.md`.
4. Para cada tarea resuelta, usar `skills/agent-routing/SKILL.md` para confirmar/asignar el agente implementador (según lo sugerido en el propio archivo de tarea) y confirmar el repositorio de destino (`repositories/<repo-name>/`, según el campo `Repositorio` de la tarea).
5. Si hay más de una tarea resoluble en paralelo sin dependencias entre sí, usar `skills/parallel-worktrees/SKILL.md` (respetando `parallelism.max_parallel_implementers`).
6. Ejecutar cada tarea siguiendo `skills/implementation-execution/SKILL.md`, escribiendo el código en el repositorio indicado.
7. Tras implementar todas las tareas de cada fase resuelta, ejecutar `review` (`skills/code-review/SKILL.md`) y `test` (`skills/test-validation/SKILL.md`) para esa fase completa.
8. Si una fase queda implementada, revisada y probada sin hallazgos bloqueantes, ejecutar `delivery` (`skills/delivery-summary/SKILL.md`) para esa fase antes de continuar con la siguiente fase pendiente.

## Expected Result

Todas las tareas seleccionadas quedan implementadas en `repositories/<repo-name>/`, revisadas y probadas. Si se seleccionó una fase entera o la feature completa, cada fase completada genera su resumen de entrega en `orchestrator/reports/F{num}-{slug}/P{fase}-delivery-summary.md`.

## Quality Gates

- El selector se resolvió a al menos una tarea existente en `features/F{num}-{slug}/P*/`; si no resuelve a ninguna, se informa al usuario y no se ejecuta nada.
- Ninguna tarea se marca como completada sin pasar por revisión y pruebas.
- Ningún cambio de código se escribió fuera de `repositories/**`.
- El uso de worktrees respeta la política de `orchestrator.yaml -> worktrees`.
