# Workflow: task-delivery

Workflow del atajo `$task F{num}-P{fase}[-T{tarea}]`. Retoma una feature ya planificada (`feature-planning.md` completado) y ejecuta `routing -> implementation -> review -> test -> delivery` para las tareas resueltas por el selector. Disparado por `skills/task-delivery-shortcut/SKILL.md`.

## Nodos

| Nodo | Agente | Hook | Artefacto de salida |
|---|---|---|---|
| `routing` | orchestrator | `hooks/pre-agent-dispatch.md` | asignación agente↔tarea |
| `implementation` | backend/frontend/fullstack-engineer | `hooks/pre-agent-dispatch.md` | cambios de código por tarea |
| `review` | code-reviewer | `hooks/pre-review.md` | `reports/<feature-id>/P*-review-report.md` |
| `test` | unit/e2e-test-engineer, qa-verifier | `hooks/pre-test.md` | `reports/<feature-id>/P*-test-report.md` |
| `delivery` | delivery-summarizer | `hooks/post-delivery.md` | `reports/<feature-id>/P*-delivery-summary.md` |

## Estados posibles

Igual que `application-feature.md`. Adicionalmente, cada tarea individual dentro de `implementation` tiene su propio sub-estado (`pending`/`running`/`waiting`/`failed`/`cancelled`/`completed`) rastreado independientemente en `runtime/state/<feature-id>.yaml`.

## Reglas de transición

1. `routing` resuelve el selector (`scripts/resolve-feature-tasks.sh`) a un conjunto concreto de tareas antes de avanzar. Si el selector no resuelve a ninguna tarea, el workflow pasa a `cancelled` inmediatamente y se informa al usuario.
2. `implementation` avanza tarea por tarea (o en paralelo si están marcadas como paralelizables y sin dependencias cruzadas).
3. `review` y `test` se ejecutan por tarea o por fase completa, según lo que el selector haya resuelto.
4. `delivery` solo se dispara automáticamente si el selector fue una fase completa (`F{num}-P{fase}`) y todas sus tareas están `completed` tras `review`/`test`. Si el selector fue una tarea individual (`F{num}-P{fase}-T{tarea}`), el workflow termina en `completed` tras `test`, sin generar resumen de entrega de fase.

## Paralelismo

- Hasta `parallelism.max_parallel_implementers` tareas de `implementation` simultáneas, cada una en su worktree si corresponde (`skills/parallel-worktrees/SKILL.md`).
- Hasta `parallelism.max_parallel_reviewers` revisiones simultáneas.

## Persistencia de estado

Cada transición de tarea y de fase se persiste en `runtime/state/<feature-id>.yaml`, permitiendo que una invocación posterior de `$task` con otro selector continúe sin reprocesar tareas ya `completed`.
