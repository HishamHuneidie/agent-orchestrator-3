# Skill: parallel-worktrees

## Trigger

Se activa cuando el trabajo a realizar es paralelo (varios implementadores simultáneos) o de alto riesgo (migraciones, refactors grandes), según la política de `orchestrator.yaml -> worktrees`.

## Parameters

- `feature_id` (obligatorio).
- `task_ids` (obligatorio): lista de identificadores de tarea a paralelizar (pueden pertenecer a distintos `repositories/<repo-name>/`).

## Inputs

- `orchestrator.yaml -> worktrees` (política, raíz, convención de nombres).
- `scripts/create-worktree.sh`, `scripts/cleanup-worktree.sh`.

## Procedure

1. Verificar que el número de tareas paralelas no excede `parallelism.max_parallel_implementers` (3). Si excede, encolar el resto en vez de lanzarlas todas.
2. Para cada tarea a paralelizar, leer su campo `Repositorio` y crear su worktree dentro de ese repo: `scripts/create-worktree.sh <repo-name> <feature-id> <task-id>`, siguiendo la convención `{feature_id}/{task_id}` bajo `repositories/<repo-name>/.worktrees/`.
3. Despachar cada implementador a su propio worktree, siguiendo `skills/implementation-execution/SKILL.md` de forma aislada.
4. Al completarse cada tarea, coordinar la integración (merge) de vuelta a la rama de trabajo de la feature, dentro del mismo repositorio, antes de limpiar.
5. Ejecutar `scripts/cleanup-worktree.sh <repo-name> <feature-id> <task-id>` tras integrar cada worktree exitosamente. No limpiar un worktree con cambios sin integrar.

## Expected Result

Múltiples tareas se implementan de forma aislada y concurrente sin interferencia entre sí, y se integran de vuelta de forma controlada.

## Quality Gates

- Nunca se excede `parallelism.max_parallel_implementers`.
- Ningún worktree se elimina con cambios sin integrar ni respaldar.
- Los conflictos de integración se resuelven explícitamente, nunca se descartan cambios silenciosamente.
- Worktrees nunca se usan para documentación, estimación o tareas secuenciales pequeñas (ver `worktrees.policy.disabled_for`).
