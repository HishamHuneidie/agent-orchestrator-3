# Skill: feature-planning-shortcut

## Trigger

Se activa con el atajo `$feat F{num}` (p. ej. `$feat F01`).

## Parameters

- `num` (obligatorio): número de la feature. El directorio de la feature ya debe existir como `features/F{num}-{slug}/` (raíz del monorepo, hermano de `orchestrator/`; creado y nombrado por el usuario), conteniendo al menos `README.md`.

## Inputs

- `features/F{num}-{slug}/README.md` (documentación de producto fuente; autoría humana, obligatoria — si no existe, la skill se detiene y lo pide).
- `workflows/feature-planning.md`.

## Procedure

1. Buscar el directorio único bajo `features/` (raíz del monorepo) cuyo nombre empieza por `F{num}-` (glob `features/F{num}-*/`). Si no existe ninguno, o existe más de uno, detener y pedir al usuario que cree/corrija el directorio (`features/F{num}-{slug}/`).
2. Verificar que `features/F{num}-{slug}/README.md` existe y no está vacío. Si no, detener y pedir al usuario que lo complete antes de continuar.
3. Derivar `feature_id` a partir del nombre del directorio (p. ej. `F01-collaborative-lab`).
4. Despachar a `feature-analyst` para producir `orchestrator/briefs/{feature_id}/brief.yaml` (alcance, criterios de aceptación, restricciones, riesgos, fuera de alcance), leyendo únicamente `README.md` como fuente.
5. Despachar a `estimator` para completar el campo `estimate` de ese mismo brief (complejidad, dependencias, tiempos).
6. Despachar a `implementation-planner` para producir:
   - `orchestrator/briefs/{feature_id}/PLAN.md` (plan de fases, usando `templates/feature-plan.md`; bookkeeping interno, no vive dentro de `features/`).
   - `features/F{num}-{slug}/P{fase}-{slug}/` (una carpeta por fase) con `T{tarea}-{slug}.md` dentro (una por tarea, usando `templates/feature-task.md`).
7. **Nunca escribir ni sobrescribir `README.md`.** Es autoría humana; esta skill solo lo lee.
8. **No implementar código en ningún paso de esta skill.**
9. Informar al usuario un resumen del plan generado (número de fases, número de tareas, estimación total) y la ruta de `PLAN.md`.

## Expected Result

`orchestrator/briefs/{feature_id}/PLAN.md` (bookkeeping interno) y las carpetas `features/F{num}-{slug}/P{fase}-{slug}/` con sus tareas contienen el plan completo, listo para ejecutarse fase por fase con `$task F{num}-P{fase}`, sin ningún cambio de código de producto ni modificación de `README.md`.

## Quality Gates

- `README.md` existe, no está vacío, y no fue modificado por esta skill.
- El brief y la estimación existen y validan contra `schemas/brief.schema.yaml` antes de planificar.
- Cada tarea generada tiene criterios de aceptación verificables y un agente implementador sugerido.
- No se tocó ningún archivo de código de producto (`repositories/**`) durante la ejecución de esta skill.
