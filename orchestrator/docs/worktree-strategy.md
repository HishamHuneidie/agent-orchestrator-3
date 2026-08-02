# Detalle de la estrategia de worktrees

## Por qué worktrees y no ramas simples

Un worktree de Git da a cada tarea paralela un directorio de trabajo completamente aislado (mismo repositorio, checkout distinto), permitiendo que múltiples implementadores (agentes) modifiquen archivos simultáneamente sin pisarse entre sí, sin necesidad de detener o clonar el repositorio completo.

## Cuándo usarlos

| Situación | Política |
|---|---|
| Documentación, estimación, planificación | **No usar** — no hay riesgo de conflicto y añaden overhead innecesario. |
| Tareas secuenciales pequeñas | **No usar** — el aislamiento no aporta valor si solo hay un implementador activo a la vez. |
| Varios implementadores en paralelo | **Obligatorio** — evita conflictos de archivo entre agentes concurrentes. |
| Migraciones, refactors grandes, alto riesgo de conflicto | **Recomendado** — permite descartar el intento completo sin afectar la rama principal si algo sale mal. |

Ver `orchestrator.yaml -> worktrees.policy`.

## Convención de nombres

El worktree se crea **dentro del repositorio de aplicación**, no en la raíz del monorepo ni en `orchestrator/`:

- Ruta: `repositories/{repo-name}/.worktrees/{feature_id}/{task_id}`
- Rama: `worktree/{feature_id}/{task_id}` (dentro del repositorio git de `repositories/{repo-name}/`)

## Ciclo de vida de un worktree

1. **Creación**: `scripts/create-worktree.sh <repo-name> <feature-id> <task-id> [base_branch]`. Crea la rama (si no existe) y el directorio bajo `repositories/<repo-name>/.worktrees/`.
2. **Trabajo**: el implementador asignado trabaja exclusivamente dentro de ese directorio.
3. **Integración**: al completar la tarea (implementación + revisión + pruebas), se integra de vuelta a la rama base de la feature dentro del mismo repositorio. Los conflictos se resuelven explícitamente, nunca se descartan cambios de un lado silenciosamente.
4. **Limpieza**: `scripts/cleanup-worktree.sh <repo-name> <feature-id> <task-id>`. Se niega a eliminar un worktree con cambios sin commitear salvo que se pase `--force` explícitamente.

## Límites de paralelismo

`orchestrator.yaml -> parallelism.max_parallel_implementers` (3) y `max_parallel_reviewers` (2) acotan cuántos worktrees de implementación/revisión pueden estar activos simultáneamente. Tareas adicionales quedan en cola (`pending`) hasta que se libera un slot.

## Riesgos si se ignora la política

- Usar worktrees para tareas triviales añade overhead de gestión sin beneficio.
- No usar worktrees para trabajo paralelo real produce conflictos de archivo directos entre agentes que están escribiendo simultáneamente en la misma rama.
- Limpiar un worktree con cambios sin integrar pierde trabajo silenciosamente — por eso `cleanup-worktree.sh` se niega a hacerlo sin `--force`.
