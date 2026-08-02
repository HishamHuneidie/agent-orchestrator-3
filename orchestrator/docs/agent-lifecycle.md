# Ciclo de vida de un agente durante una task

Este documento describe, paso a paso, qué ocurre desde que se decide invocar a un agente hasta que su output queda persistido y el workflow avanza.

## 1. Selección

`orchestrator` (o el cliente de IA actuando como tal) determina, vía `skills/agent-routing/SKILL.md`, qué agente ejecuta la fase/tarea actual, según `orchestrator.yaml -> phases` y `agent_selection`.

## 2. Verificación previa (`pre-agent-dispatch`)

Antes de invocar al agente, se ejecuta `hooks/pre-agent-dispatch.md` (`runtime/hooks/pre-agent-dispatch.sh`): confirma que los inputs obligatorios existen y que ninguna ruta objetivo cae en `security.forbidden_roots`.

## 3. Construcción del prompt

El cliente de IA adopta el contrato completo de `agents/<agent>.md` y construye el contexto siguiendo `templates/prompt.md` (ver `docs/prompt-builder.md`), incluyendo inputs, restricciones de permisos y el output esperado.

## 4. Ejecución

El agente ejecuta su "Flujo interno de ejecución" tal como está documentado en su contrato, respetando sus checklists de ejecución y calidad, y sus límites de archivos/herramientas.

## 5. Verificación posterior (`post-agent-dispatch`)

Al terminar, se ejecuta `hooks/post-agent-dispatch.md` (`runtime/hooks/post-agent-dispatch.sh`): valida el artefacto producido contra su schema en `schemas/`, escanea en busca de secretos, y solo entonces se acepta como completado.

## 6. Persistencia y observabilidad

El resultado (éxito o fallo) se persiste en `runtime/state/<feature-id>.yaml` y se registra un evento en `observability/executions.jsonl` (ver `docs/observability.md`).

## 7. Handoff

Según la "Estrategia de handoff" del contrato del agente, el output se entrega al siguiente agente en la secuencia (por ejemplo, `feature-analyst` entrega a `estimator`, que entrega a `implementation-planner`).

## Manejo de fallos en cualquier punto del ciclo

- Errores reintentables: se reintenta según `retry_policy` (backoff `[5, 30]` segundos, hasta `max_retries: 2`).
- Errores no reintentables (`security_violation`, `secret_detected`, `schema_validation_failed`, `permission_denied`): el ciclo se detiene inmediatamente, la fase pasa a `failed`, y se requiere intervención humana antes de continuar.
