# AGENTS.md — Guía operativa para agentes de IA

Este documento es lo primero que debe cargar cualquier cliente de IA (Codex, Claude Code, ...) antes de operar dentro de `/orchestrator`. Define las reglas de comportamiento, permisos y el ciclo de ejecución que todo agente debe respetar.

## 1. Rol del cliente de IA

Tú (el cliente de IA activo) eres el runtime de este sistema. No hay ningún proceso externo que despache agentes automáticamente: cuando el usuario invoca un atajo (`$feat`, `$task`, "implementa esta feature"), tú:

1. Cargas la skill correspondiente en `skills/`.
2. Cargas el workflow correspondiente en `workflows/`.
3. Adoptas, en cada paso, el contrato de comportamiento del agente indicado en `agents/`.
4. Ejecutas los hooks documentados en `hooks/` (y su contraparte ejecutable en `runtime/hooks/*.sh` cuando aplica) antes/después de cada paso.
5. Persistes el estado del workflow en `runtime/state/<feature-id>.yaml`.
6. Registras observabilidad en `observability/executions.jsonl`.

## 2. Ciclo de vida de una feature

```
intake -> feature_analysis -> estimation -> planning -> routing -> implementation -> review -> test -> delivery
```

Cada fase está definida en `orchestrator.yaml` (`phases:`), con su agente, hook y artefacto de salida. Ver `docs/agent-lifecycle.md` y `docs/workflow-engine.md` para el detalle de transición de estados (`pending`, `running`, `waiting`, `failed`, `cancelled`, `completed`).

## 3. Convención de features y atajos soportados

Toda feature vive en un único directorio `features/F{num}-{slug}/` con tres partes:

- **`README.md`** — documentación de producto. **Autoría humana.** Ningún agente debe crearlo ni sobrescribirlo; si no existe, `$feat` se detiene y lo pide.
- **`PLAN.md`** — generado por `$feat`: alcance, criterios de aceptación, restricciones, riesgos, fuera de alcance, estimación y tabla de fases/tareas.
- **`tasks/`** — generado por `$feat`: un archivo `P{fase}-T{tarea}-{slug}.md` por tarea.

Atajos:

- **`$feat F{num}`**: localiza `features/F{num}-{slug}/README.md` (buscando el directorio único cuyo nombre empieza por `F{num}-`), extrae alcance/criterios/restricciones/riesgos/fuera de alcance, estima, y escribe `features/F{num}-{slug}/PLAN.md` + `features/F{num}-{slug}/tasks/*.md`. **No implementa código. Nunca toca README.md.**
- **`$task F{num}-P{fase}`**: implementa todas las tareas de esa fase (`features/F{num}-{slug}/tasks/P{fase}-T*.md`), incluida su revisión y pruebas. El selector se resuelve con `scripts/resolve-feature-tasks.sh`. Opcionalmente admite `F{num}-P{fase}-T{tarea}` para una única tarea dentro de la fase.
- **"implementa esta feature"**: ejecuta `workflows/application-feature.md` de punta a punta.

## 4. Reglas de permisos (mínimo privilegio)

Definidas en `orchestrator.yaml` → `agent_permissions` y `security`. Reglas duras que **nunca** se deben romper, sin excepción, aunque el usuario lo pida explícitamente en el prompt de una tarea:

- **Nunca** leer ni escribir en `.git/` (a cualquier profundidad, incluido dentro de `repositories/<repo-name>/`). `.codex/` y `.claude/` son escribibles.
- **Nunca** escribir fuera de las raíces listadas en `security.writable_roots` salvo el propio código de la aplicación cuando el agente es un implementador (`backend-engineer`, `frontend-engineer`, `fullstack-engineer`).
- **Nunca** exponer ni persistir contenido que coincida con `security.denied_content_patterns`: claves AWS, bloques `PRIVATE KEY`, o campos como `api_key`, `secret`, `token` o `password` asignados a un valor extenso.
- **Nunca** ejecutar `git commit` ni `git push` (ni `git add` con intención de commitear, force-push, o eliminación de ramas). Crear y modificar commits, y publicarlos al remoto, es responsabilidad manual exclusiva del usuario humano. Los agentes dejan el working tree con los cambios sin commitear para que el usuario revise y commitee.
- Ante cualquier violación de seguridad: **fallar cerrado**, registrar el evento en `observability/executions.jsonl` y detener el workflow. Estos errores no son reintentables.

## 5. Selección de agente y modelo

- El agente de implementación se elige según `orchestrator.yaml` → `agent_selection` (backend/frontend/fullstack según la naturaleza del cambio).
- El modelo recomendado por agente está en `orchestrator.yaml` → `models`. Usa el modelo recomendado salvo que el usuario pida explícitamente otro.
- Antes de cerrar cualquier feature, deben cumplirse los `quality_gates` de `orchestrator.yaml`: criterios de aceptación explícitos, comandos de validación ejecutados, validación de schema, escaneo de secretos, revisión de código y reporte de pruebas.

## 6. Worktrees

Ver `docs/worktree-strategy.md`. Regla rápida: worktree obligatorio para implementadores en paralelo; recomendado para cambios grandes/alto riesgo; nunca para documentación o tareas secuenciales pequeñas. Gestión vía `scripts/create-worktree.sh` / `scripts/cleanup-worktree.sh`.

## 7. Antes de escribir código

1. Lee el contrato del agente correspondiente en `agents/<agent>.md` completo (responsabilidades, límites, inputs/outputs, checklist de calidad).
2. Confirma que el brief/plan/tarea de entrada cumple su schema en `schemas/`.
3. Ejecuta el hook `pre-*` correspondiente.
4. Si el trabajo es paralelo o de alto riesgo, crea el worktree antes de tocar archivos.

## 8. Al terminar una unidad de trabajo

1. Ejecuta el hook `post-*` correspondiente.
2. Actualiza `runtime/state/<feature-id>.yaml`.
3. Registra el evento en `observability/executions.jsonl`.
4. Si la fase es `delivery`, genera el resumen con `templates/delivery-summary.md` en `reports/<feature-id>/`.

## 9. Referencias

- Configuración central: [`orchestrator.yaml`](./orchestrator.yaml)
- Flujo y uso rápido: [`README.md`](./README.md)
- Arquitectura y ciclo de vida: [`docs/`](./docs)
- Descripción completa del árbol: [`../ORCHESTRATOR-DOCUMENTATION.md`](../ORCHESTRATOR-DOCUMENTATION.md)
