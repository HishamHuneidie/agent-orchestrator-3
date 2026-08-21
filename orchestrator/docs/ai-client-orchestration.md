# Cómo el cliente de IA activo ejecuta la orquestación

## No hay runtime externo

No existe ningún proceso fuera del propio cliente de IA (Codex, Claude Code, ...) que despache agentes. Cuando el usuario escribe `$feat F01`, `$task F01-P00`, `$task F01` o "implementa esta feature" dentro de su sesión con el cliente de IA, es **ese mismo cliente** quien:

1. Reconoce el atajo (definido en `orchestrator.yaml -> runtime.entrypoints`).
2. Carga la skill asociada (`skills/.../SKILL.md`) y el workflow asociado (`workflows/*.md`).
3. Por cada nodo del workflow, "se convierte" temporalmente en el agente indicado, adoptando el contrato de `agents/<agent>.md` como su comportamiento para esa unidad de trabajo.
4. Ejecuta los hooks (`hooks/*.md` + `runtime/hooks/*.sh`) en los puntos de control correspondientes, normalmente invocando el script `.sh` vía su herramienta de shell.
5. Lee y escribe los artefactos (briefs, planes, tareas, reportes) usando sus propias herramientas de lectura/escritura de archivos.

## Qué significa "convertirse" en un agente

El cliente de IA no cambia de proceso ni de sesión: simplemente restringe su comportamiento, para esa unidad de trabajo, a lo que dicta `agents/<agent>.md` — sus responsabilidades, sus no-responsabilidades, sus límites de archivos y herramientas, y sus checklists. Esto es una convención de disciplina operativa, reforzada por los hooks de seguridad que sí son código ejecutable real y no dependen de la buena voluntad del modelo.

## Por qué esto es suficiente

- El cliente de IA ya sabe leer/escribir archivos, ejecutar comandos de shell, y razonar sobre instrucciones en lenguaje natural — no hace falta reconstruir esas capacidades en un runtime aparte.
- Los hooks ejecutables (`runtime/hooks/*.sh`) actúan como la "red de seguridad" dura: aunque el modelo se equivoque de contrato, el hook de seguridad falla cerrado ante un secreto detectado o una ruta prohibida, independientemente de qué agente crea estar ejecutando.
- El estado persistido en `runtime/state/<feature-id>.yaml` permite que **cualquier** sesión posterior (incluso de un cliente de IA distinto) reanude exactamente donde quedó la anterior.

## Multi-cliente

`orchestrator.yaml -> runtime.supported_clients` declara `codex` y `claude-code` como clientes soportados. Ambos ejecutan el mismo protocolo descrito arriba; no hay lógica condicional por cliente en los contratos — el contrato es el mismo texto para cualquier cliente que sepa seguirlo.
