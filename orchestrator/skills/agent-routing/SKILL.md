# Skill: agent-routing

## Trigger

Se activa cada vez que el `orchestrator` necesita decidir qué agente(s) deben ejecutar una unidad de trabajo (una fase del workflow o una tarea concreta de `features/F{num}-{slug}/`).

## Parameters

- `phase` (obligatorio): fase del workflow actual (`intake`, `feature_analysis`, `estimation`, `planning`, `routing`, `implementation`, `review`, `test`, `delivery`).
- `task_ref` (opcional): referencia a una tarea concreta (`P{fase}-T{tarea}`) cuando la fase es `implementation` o `test`.

## Inputs

- `orchestrator.yaml -> phases` (mapeo fase → agente por defecto).
- `orchestrator.yaml -> agent_selection` (criterios de desambiguación para implementadores y testers).
- El archivo de tarea (`features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-*.md`) cuando aplica, que declara el agente sugerido por `implementation-planner`.

## Procedure

1. Si la fase tiene un único agente posible en `orchestrator.yaml -> phases`, seleccionarlo directamente.
2. Si la fase es `implementation`, leer el campo de agente sugerido en el archivo de tarea. Si no está presente o es ambiguo, aplicar `agent_selection.implementer`:
   - Naturaleza del cambio en `[api, database, jobs, integrations, server-logic]` → `backend-engineer`.
   - Naturaleza del cambio en `[ui, ux, client-state, accessibility, styling]` → `frontend-engineer`.
   - Cambio pequeño cross-stack o glue code → `fullstack-engineer`.
3. Si la fase es `test`, aplicar `agent_selection.tester`:
   - Lógica pura/servicios/componentes → `unit-test-engineer`.
   - Flujos críticos de usuario → `e2e-test-engineer`.
   - Ambos pueden ejecutarse en paralelo si la tarea lo justifica.
4. Verificar que el agente seleccionado tiene permisos suficientes según `orchestrator.yaml -> agent_permissions` para los archivos que va a tocar. Si no los tiene, escalar al usuario en vez de forzar la asignación.
5. Registrar la decisión de enrutamiento en `runtime/state/<feature-id>.yaml`.

## Expected Result

El agente correcto queda asignado a la unidad de trabajo, con sus permisos verificados, y la decisión queda persistida para trazabilidad.

## Quality Gates

- Ninguna unidad de trabajo se despacha sin un agente asignado explícitamente.
- Ninguna asignación viola `agent_permissions` para las rutas que la tarea requiere modificar.
- Toda decisión de enrutamiento queda registrada en el estado del workflow.
