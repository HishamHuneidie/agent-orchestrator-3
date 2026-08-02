# Hook: pre-agent-dispatch

## Propósito

Se ejecuta antes de despachar trabajo a cualquier agente (analista, estimador, planificador, implementador, etc.). Verifica permisos, disponibilidad de inputs obligatorios y ausencia de violaciones de seguridad antes de invocar al agente.

## Cuándo se ejecuta

Inmediatamente antes de que `orchestrator` (vía `skills/agent-routing/SKILL.md`) invoque a cualquier agente para ejecutar una fase o tarea.

## Inputs

- Nombre del agente a despachar.
- Ruta(s) de archivo que el agente leerá/escribirá.
- Artefactos de entrada obligatorios (brief, plan, tarea, según la fase).

## Outputs

- Confirmación de que el despacho puede proceder, o un bloqueo con el motivo (permiso insuficiente, input faltante, ruta prohibida).

## Errores posibles

- El agente intenta escribir fuera de las raíces permitidas por `orchestrator.yaml -> agent_permissions`.
- Falta un input obligatorio (p. ej. despachar `implementation-planner` sin brief ni estimación).
- La ruta objetivo coincide con `security.denied_path_patterns` o `security.forbidden_roots`.

## Componente ejecutable correspondiente

`runtime/hooks/pre-agent-dispatch.sh`
