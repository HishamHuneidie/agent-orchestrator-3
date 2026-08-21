# Manual operativo general

## Arrancar con una feature nueva

1. En la **raíz del monorepo** (no dentro de `orchestrator/`), crea manualmente `features/F{num}-{slug}/README.md` o genera/actualiza ese archivo con `$docu` tras aprobación explícita. Debe contener alcance, criterios de aceptación, restricciones, riesgos y fuera de alcance. Para `$feat`, `$task` y los agentes de implementación, este archivo siempre es de solo lectura.
2. En tu cliente de IA (con `AGENTS.md` cargado), escribe: `$feat F{num}` (p. ej. `$feat F01`).
3. Revisa las carpetas de fase generadas en `features/F{num}-{slug}/P{fase}-{slug}/` y sus tareas (`T*.md`) antes de implementar nada.
4. Cuando el plan esté aprobado, escribe: `$task F{num}-P{fase}` (p. ej. `$task F01-P01`) para desarrollar esa fase completa (implementación + revisión + pruebas), o `$task F{num}` (p. ej. `$task F01`) para desarrollar todas las fases planificadas de la feature. El código se escribe en `repositories/<repo-name>/`.
5. Al terminar cada fase, revisa `orchestrator/reports/F{num}-{slug}/P{fase}-delivery-summary.md`.
6. Si estás ejecutando fase por fase, repite el paso 4 con la siguiente fase (`$task F01-P02`, ...) hasta completar todas las fases del plan.

## Reanudar una feature interrumpida

El estado vive en `runtime/state/<feature-id>.yaml`. Simplemente vuelve a invocar `$task F{num}-P{fase}` (la misma fase en la que quedó) o `$task F{num}` si estabas ejecutando la feature completa; el workflow retoma desde el primer nodo no `completed`. Usa `./orchestrator status <feature-id>` para inspeccionar el estado actual sin modificarlo.

## Trabajar en paralelo

Si el plan marca varias tareas como paralelizables (ver `Worktree: required|recommended` en cada tarea), el cliente de IA usará `scripts/create-worktree.sh` automáticamente al despachar esas tareas. Puedes crear/limpiar worktrees manualmente si necesitas intervenir (el worktree se crea **dentro del repositorio de aplicación correspondiente**, no en la raíz del monorepo):

```bash
scripts/create-worktree.sh <repo-name> <feature-id> <task-id>
scripts/cleanup-worktree.sh <repo-name> <feature-id> <task-id>
```

## Validar el repositorio

```bash
./orchestrator validate          # estructura del orquestador
scripts/validate-contract.sh briefs/mi-feature/brief.yaml
scripts/security-scan.sh         # secretos/rutas denegadas (incluye repositories/**)
```

Para validar también el layout completo del monorepo (raíz), usa `make validate` desde la raíz, o `./orchestrator validate --monorepo` (ver `scripts/validate-structure.sh`).

## Diagnosticar un fallo

1. Revisa `observability/executions.jsonl` filtrando por `feature_id` (ver `docs/observability.md`).
2. Revisa `runtime/state/<feature-id>.yaml` para ver en qué nodo y estado quedó.
3. Si el fallo es de seguridad (`security_violation`/`secret_detected`), **no reintentes** automáticamente: revisa manualmente el contenido señalado antes de continuar.

## Compatibilidad v1

Si trabajas con artefactos legados (`execution-plan.yaml`, `agent-task.yaml`), estos siguen siendo válidos (`orchestrator.yaml -> supports_v1_contracts: true`) y se validan con los mismos `scripts/validate-contract.sh` contra `schemas/execution-plan.schema.yaml`/`schemas/agent-task.schema.yaml`. No es necesario migrar features en curso al formato v2 (Markdown en `features/`) para poder seguir operándolas.
