# Workflow: delivery-summary

Workflow de cierre de entrega para una fase o feature completa. Último tramo de `application-feature.md` y `task-delivery.md` (cuando el selector resuelve una fase completa).

## Nodos

| Nodo | Agente | Hook | Artefacto de salida |
|---|---|---|---|
| `gate_check` | orchestrator | — | verificación de `quality_gates` satisfechos |
| `delivery` | delivery-summarizer | `hooks/post-delivery.md` | `reports/<feature-id>/P*-delivery-summary.md` |
| `state_close` | orchestrator | — | `runtime/state/<feature-id>.yaml` actualizado a `completed` |

## Estados posibles

`pending`, `running`, `waiting`, `failed`, `cancelled`, `completed` (por nodo).

## Reglas de transición

1. `gate_check` verifica, antes de nada, que `orchestrator.yaml -> quality_gates` está satisfecho: criterios de aceptación explícitos, comandos de validación ejecutados, schema válido, escaneo de secretos limpio, revisión de código sin bloqueantes, reporte de pruebas sin bloqueantes.
2. Si `gate_check` falla en cualquier punto, el workflow pasa a `waiting` (o `failed` si el fallo es de seguridad, no reintentable) y **no** se genera el resumen de entrega.
3. `delivery` solo se ejecuta tras `gate_check` en `completed`.
4. `state_close` marca la fase/feature como `completed` en el estado persistido solo después de que `delivery` haya generado su artefacto correctamente.

## Paralelismo

No aplica: este workflow es intrínsecamente secuencial (es el cierre formal de la entrega).

## Persistencia de estado

`runtime/state/<feature-id>.yaml` queda con la fase/feature en `completed`, con referencia al resumen de entrega generado en `reports/<feature-id>/`.
