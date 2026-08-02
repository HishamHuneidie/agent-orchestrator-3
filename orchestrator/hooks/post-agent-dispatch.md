# Hook: post-agent-dispatch

## Propósito

Se ejecuta después de que un agente termina su unidad de trabajo. Valida el output producido contra su schema, escanea en busca de secretos, y registra observabilidad antes de permitir que el workflow avance al siguiente nodo.

## Cuándo se ejecuta

Inmediatamente después de que cualquier agente reporta haber completado su fase/tarea.

## Inputs

- Artefacto(s) producido(s) por el agente (brief, estimación, plan, código, reporte).
- Schema esperado (`schemas/*.schema.yaml`) para artefactos estructurados.

## Outputs

- Confirmación de que el output es válido y puede persistirse/propagarse, o un rechazo con el motivo.
- Evento registrado en `observability/executions.jsonl`.
- `runtime/state/<feature-id>.yaml` actualizado con el resultado de la fase/tarea.

## Errores posibles

- El artefacto no valida contra su schema (`scripts/validate-contract.sh`).
- Se detecta contenido que coincide con `security.denied_content_patterns` (secreto/token/clave).
- El agente reporta éxito pero no produjo el artefacto esperado en la ruta esperada.

## Componente ejecutable correspondiente

`runtime/hooks/post-agent-dispatch.sh`
