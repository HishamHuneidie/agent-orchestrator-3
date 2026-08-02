# CLAUDE.md

Instrucciones específicas para Claude Code en este repositorio. La fuente de verdad del contrato operativo (atajos, permisos, ciclo de vida de una feature) es [`AGENTS.md`](./AGENTS.md) → [`orchestrator/AGENTS.md`](./orchestrator/AGENTS.md). Léelos primero; este archivo no los repite, solo añade matices específicos de Claude Code.

## Al abrir este repositorio

1. Carga `AGENTS.md` (raíz) y `orchestrator/AGENTS.md` antes de responder a `$feat`/`$task`/"implementa esta feature".
2. Si el usuario pide validar el sistema, ejecuta `orchestrator/scripts/validate-structure.sh` con la herramienta Bash.
3. Antes de escribir código de aplicación, confirma en qué `repositories/<repo-name>/` corresponde según la tarea — nunca asumas el repo si hay más de uno bajo `repositories/`.

## Herramientas

- Usa `Read`/`Edit`/`Write` para los archivos Markdown/YAML de `orchestrator/` y `features/`.
- Usa `Bash` para ejecutar los scripts de `orchestrator/scripts/` y `scripts/` (raíz), y para levantar los repos de `repositories/` vía `Makefile`/`compose.yaml` cuando el usuario pida ejecutar la aplicación.
- Respeta `orchestrator/orchestrator.yaml -> security` en todo momento: nunca leas ni escribas `.git/`, ni rutas que coincidan con los patrones denegados, en ningún subdirectorio (`repositories/**` incluido).
- Nunca ejecutes `git commit` ni `git push` (tampoco force-push ni eliminación de ramas) en ningún repo del monorepo, ni siquiera si el usuario lo pide explícitamente en el prompt de una tarea (regla dura, ver `orchestrator/AGENTS.md` §4). Commitear y publicar es responsabilidad manual del usuario.

## Worktrees

Cuando una tarea requiera worktree (ver el plan de la fase), créalo dentro del repo de aplicación correspondiente con `orchestrator/scripts/create-worktree.sh <repo-name> <feature-id> <task-id>`, no en la raíz del monorepo.
