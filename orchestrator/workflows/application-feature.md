# Workflow: application-feature

Workflow stateful completo: `intake -> feature_analysis -> estimation -> planning -> routing -> implementation -> review -> test -> delivery`. Disparado por la skill `skills/application-feature-orchestration/SKILL.md` cuando el usuario pide "implementa esta feature".

## Nodos

| Nodo | Agente | Hook | Artefacto de salida |
|---|---|---|---|
| `intake` | orchestrator | `hooks/pre-orchestration.md` | `runtime/state/<feature-id>.yaml` (creado) |
| `feature_analysis` | feature-analyst | `hooks/pre-agent-dispatch.md` | `briefs/<feature-id>/brief.yaml` |
| `estimation` | estimator | `hooks/post-agent-dispatch.md` | `briefs/<feature-id>/estimate.yaml` |
| `planning` | implementation-planner | `hooks/post-agent-dispatch.md` | `orchestrator/briefs/<feature-id>/PLAN.md` + `features/<feature-id>/P*-*/T*.md` |
| `routing` | orchestrator | `hooks/pre-agent-dispatch.md` | asignación agente↔tarea en el estado |
| `implementation` | backend/frontend/fullstack-engineer | `hooks/pre-agent-dispatch.md` | cambios de código |
| `review` | code-reviewer | `hooks/pre-review.md` | `reports/<feature-id>/P*-review-report.md` |
| `test` | unit/e2e-test-engineer, qa-verifier | `hooks/pre-test.md` | `reports/<feature-id>/P*-test-report.md` |
| `delivery` | delivery-summarizer | `hooks/post-delivery.md` | `reports/<feature-id>/P*-delivery-summary.md` |

## Estados posibles (por nodo)

`pending` → `running` → (`waiting` | `completed` | `failed` | `cancelled`)

- **pending**: nodo aún no iniciado.
- **running**: agente actualmente ejecutando la fase.
- **waiting**: esperando una dependencia (otra tarea/fase) o input humano.
- **failed**: la fase falló y agotó sus reintentos, o falló con un error no reintentable.
- **cancelled**: la fase fue cancelada (por el usuario o por fallo no recuperable de una dependencia).
- **completed**: la fase terminó satisfaciendo sus quality gates.

## Reglas de transición

1. Un nodo solo pasa a `running` cuando todas sus dependencias directas están en `completed`.
2. `review` y `test` solo pueden iniciar cuando al menos una tarea de `implementation` está `completed`.
3. Si `review` o `test` detectan hallazgos bloqueantes, el nodo correspondiente de `implementation` vuelve a `pending` (reintento) hasta `retry_policy.max_retries`; agotados los reintentos, la fase pasa a `failed` y el workflow se detiene.
4. `delivery` solo puede iniciar cuando `review` y `test` de la fase están en `completed` sin hallazgos bloqueantes pendientes.
5. Un error clasificado en `retry_policy.non_retryable_errors` fuerza inmediatamente `failed`, sin reintentos, y detiene el workflow completo (no solo el nodo).

## Paralelismo

- `implementation` puede tener hasta `parallelism.max_parallel_implementers` (3) tareas `running` simultáneamente, cada una en su propio worktree si la tarea lo requiere (ver `skills/parallel-worktrees/SKILL.md`).
- `review` puede tener hasta `parallelism.max_parallel_reviewers` (2) revisiones simultáneas.
- Por defecto (`parallelism.default_mode: sequential`), el paralelismo es opt-in por fase/tarea, no automático.

## Persistencia de estado

El estado completo del workflow (nodo actual, estados por nodo, artefactos generados, reintentos consumidos) se persiste en `runtime/state/<feature-id>.yaml`, conforme a `schemas/workflow-state.schema.yaml`, y se actualiza tras cada transición de nodo. Permite reanudar una feature interrumpida sin perder progreso.
