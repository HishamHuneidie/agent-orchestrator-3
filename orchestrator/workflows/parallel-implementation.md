# Workflow: parallel-implementation

Workflow especializado para la fase `implementation` cuando varias tareas se ejecutan en paralelo usando worktrees aislados. Invocado desde `task-delivery.md`/`application-feature.md` cuando el plan marca tareas como paralelizables, vía `skills/parallel-worktrees/SKILL.md`.

## Nodos

| Nodo | Agente | Hook | Artefacto de salida |
|---|---|---|---|
| `worktree_setup` | orchestrator | — | `.worktrees/<feature-id>/<task-id>` creado |
| `implementation[N]` | backend/frontend/fullstack-engineer | `hooks/pre-agent-dispatch.md` | cambios de código en el worktree N |
| `integration` | orchestrator | `hooks/post-agent-dispatch.md` | merge del worktree a la rama de la feature |
| `worktree_teardown` | orchestrator | — | worktree eliminado (`scripts/cleanup-worktree.sh`) |

## Estados posibles

Cada `implementation[N]` es independiente: `pending`, `running`, `waiting`, `failed`, `cancelled`, `completed`. El nodo `integration` depende del conjunto de `implementation[N]` que se estén integrando juntos.

## Reglas de transición

1. `worktree_setup` debe completarse (worktree creado) antes de que su `implementation[N]` correspondiente pase a `running`.
2. Cada `implementation[N]` es completamente aislado: un fallo en una tarea paralela no bloquea a las demás.
3. `integration` solo procesa worktrees cuyo `implementation[N]` esté `completed` (revisado y probado, si el plan lo exige antes de integrar; de lo contrario, integra y deja `review`/`test` para después según el workflow padre).
4. Conflictos de integración detectados en `integration` se resuelven explícitamente (nunca se descartan cambios de un lado silenciosamente); si no pueden resolverse automáticamente, el nodo pasa a `waiting` y se escala al usuario.
5. `worktree_teardown` solo se ejecuta tras `integration` exitosa. Nunca se limpia un worktree con cambios sin integrar.

## Paralelismo

Límite estricto: `parallelism.max_parallel_implementers` (3) worktrees de implementación activos simultáneamente. Tareas adicionales quedan `pending` en cola hasta que se libere un slot.

## Persistencia de estado

`runtime/state/<feature-id>.yaml` mantiene una entrada por worktree activo (ruta, tarea asociada, estado), permitiendo detectar y limpiar worktrees huérfanos en una sesión posterior.
