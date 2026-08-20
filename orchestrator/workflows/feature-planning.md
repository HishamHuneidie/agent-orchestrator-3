# Workflow: feature-planning

Workflow del atajo `$feat F{num}`. Subconjunto de `application-feature.md` que se detiene tras `planning`, sin llegar a `implementation`. Disparado por `skills/feature-planning-shortcut/SKILL.md`.

## Nodos

| Nodo | Agente | Hook | Artefacto de salida |
|---|---|---|---|
| `intake` | orchestrator | `hooks/pre-orchestration.md` | `runtime/state/<feature-id>.yaml` (creado) |
| `feature_analysis` | feature-analyst | `hooks/pre-agent-dispatch.md` | `briefs/<feature-id>/brief.yaml` |
| `estimation` | estimator | `hooks/post-agent-dispatch.md` | `briefs/<feature-id>/estimate.yaml` |
| `planning` | implementation-planner | `hooks/post-agent-dispatch.md` | `orchestrator/briefs/<feature-id>/PLAN.md` + `features/<feature-id>/P*-*/T*.md` |

## Estados posibles

Igual que `application-feature.md`: `pending`, `running`, `waiting`, `failed`, `cancelled`, `completed`.

## Reglas de transición

1. Secuencial estricto: `intake -> feature_analysis -> estimation -> planning`, sin paralelismo.
2. Si `feature_analysis` detecta que `features/F{num}-{slug}/README.md` no existe o está vacío, el workflow pasa a `failed` inmediatamente (no reintentable: falta de input, no un error transitorio).
3. Al completar `planning`, el workflow completo pasa a `completed`. **No continúa automáticamente a `implementation`** — eso requiere que el usuario invoque `$task` explícitamente.

## Paralelismo

No aplica: este workflow es intrínsecamente secuencial y de bajo riesgo (solo genera documentación/planes, nunca código), por lo que nunca requiere worktrees (ver `orchestrator.yaml -> worktrees.policy.disabled_for`).

## Persistencia de estado

`runtime/state/<feature-id>.yaml` queda con el nodo `planning` en `completed` y los nodos de implementación/revisión/pruebas/entrega en `pending`, listos para ser retomados por el workflow `task-delivery.md`.
