# Semántica de nodos/estados de los workflows

## Nodos

Cada workflow en `workflows/*.md` define una secuencia de **nodos**. Un nodo representa una fase (`intake`, `feature_analysis`, ...) o, dentro de `implementation`, una tarea individual (`P{fase}-T{tarea}`). Cada nodo declara:

- El agente responsable de ejecutarlo.
- El hook a ejecutar antes/después.
- El artefacto de salida esperado.

## Estados

Todo nodo transita por el mismo conjunto de estados, sea cual sea el workflow:

```
pending -> running -> completed
              |
              +--> waiting   (esperando dependencia o input humano)
              |
              +--> failed    (agotó reintentos o error no reintentable)
              |
              +--> cancelled (cancelado explícitamente o por fallo aguas arriba)
```

- **pending**: no iniciado. Estado inicial de todo nodo al crear el estado de la feature.
- **running**: el agente correspondiente está ejecutando activamente esta fase/tarea.
- **waiting**: bloqueado por una dependencia no completada, o esperando una decisión humana (p. ej. un conflicto de integración sin resolución automática).
- **failed**: la fase falló y agotó `retry_policy.max_retries`, o falló con un error en `retry_policy.non_retryable_errors`.
- **cancelled**: cancelado por el usuario, o en cascada porque una dependencia entró en `failed`/`cancelled`.
- **completed**: la fase terminó y satisfizo todos sus quality gates aplicables.

## Reglas de transición generales

1. Un nodo solo puede pasar a `running` cuando **todas** sus dependencias directas (declaradas en el workflow o en el propio artefacto de tarea vía `depends_on`) están en `completed`.
2. Un fallo en un nodo no reintentable detiene el workflow completo, no solo ese nodo (ver `retry_policy.non_retryable_errors` en `orchestrator.yaml`).
3. Un fallo reintentable reintenta el mismo nodo con backoff (`retry_policy.backoff_seconds: [5, 30]`) hasta `max_retries: 2`; agotados los reintentos, el nodo pasa a `failed`.
4. Los nodos de `review`/`test` que detectan hallazgos bloqueantes fuerzan que el nodo de `implementation` correspondiente vuelva a `pending` (no `failed`): esto es una transición normal del ciclo de calidad, no un error del sistema.

## Paralelismo

Los workflows que lo permiten (`parallel-implementation.md`, y las secciones de `implementation`/`review` de los demás) etiquetan explícitamente el límite de concurrencia aplicable (`parallelism.max_parallel_implementers`, `max_parallel_reviewers`). Fuera de esos límites, los nodos adicionales quedan `pending` en cola.

## Persistencia y reanudación

El estado completo (nodo actual por workflow, estado de cada nodo, artefactos generados, contador de reintentos consumidos) vive en `runtime/state/<feature-id>.yaml`, conforme a `schemas/workflow-state.schema.yaml`. Cualquier sesión puede reanudar un workflow leyendo este archivo y determinando el primer nodo no `completed` como punto de partida.
