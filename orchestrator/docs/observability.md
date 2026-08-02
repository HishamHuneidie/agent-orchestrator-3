# Qué y cómo se registra en observability/

## Formato

Todo evento se registra como una línea JSON (JSONL) en `observability/executions.jsonl`, conforme a `schemas/observability-event.schema.yaml`. Se escribe mediante `runtime/lib/observability.sh -> log_event`.

Cada línea tiene la forma:

```json
{"timestamp":"2026-08-02T12:00:00Z","event_type":"hook","feature_id":"mi-feature","phase":"review","status":"ok","detail":"pre-review completado"}
```

## Tipos de evento (`event_type`)

- **hook**: ejecución de un hook (`pre-*`/`post-*`), con `status: ok|failed`.
- **error**: cualquier fallo capturado durante una fase (no reintentable o tras agotar reintentos).
- **metric**: punto de dato agregable (duración, coste, reintentos).

## Métricas agregadas

Definidas en `orchestrator.yaml -> observability.metrics`, calculadas a partir de `executions.jsonl`:

- `tasks_completed`
- `tasks_failed`
- `average_task_duration_seconds`
- `average_cost_usd_per_task`
- `retries_triggered`
- `security_violations_detected`

## Por qué JSONL

- Append-only: cada evento es una escritura independiente, sin necesidad de reescribir el archivo completo (seguro incluso si dos agentes escriben cerca en el tiempo).
- Fácil de procesar línea a línea con herramientas estándar (`jq`, `grep`, scripts Python) sin parsear un documento completo.
- Cada línea es auto-contenida y válida por sí misma, a diferencia de un array JSON que requiere el archivo completo bien formado.

## Uso típico

```bash
# Eventos de una feature concreta
grep '"feature_id":"mi-feature"' observability/executions.jsonl

# Errores no reintentables recientes
grep '"event_type":"error"' observability/executions.jsonl | tail -20

# Con jq, si está disponible
jq -c 'select(.status=="failed")' observability/executions.jsonl
```

## Relación con `runtime/state/`

`observability/executions.jsonl` es el **historial** de lo ocurrido (append-only, nunca se reescribe). `runtime/state/<feature-id>.yaml` es el **estado actual** (se sobrescribe en cada transición). Ambos se actualizan juntos en cada hook `post-*`, pero cumplen roles distintos: uno para auditoría/métricas, el otro para control de flujo y reanudación.
