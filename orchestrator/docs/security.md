# Política de seguridad, clasificación y rutas denegadas

## Principio: mínimo privilegio explícito

Todo lo que un agente puede leer, escribir o ejecutar está declarado explícitamente en `orchestrator.yaml`. Nada se asume por defecto como permitido; lo que no está listado en `agent_permissions`/`security.writable_roots` se trata como no permitido.

## Niveles de clasificación

`orchestrator.yaml -> security.classification_levels`: `public`, `internal`, `restricted`, `secret`. Estos niveles informan qué tan cuidadosamente debe tratarse un artefacto o ruta; el escaneo automático (`scripts/security-scan.sh`) trata cualquier coincidencia con los patrones denegados como si fuera `secret`, independientemente de dónde aparezca.

## Rutas denegadas por patrón (`security.denied_path_patterns`)

- `*.env`, `*.env.*`
- Cualquier ruta que contenga `secret`, `token` o `credential`
- Certificados: `*.pem`, `*.crt`
- Claves privadas: `*.key`, `*.p12`, `id_rsa*`, `id_ed25519*`

Estas rutas ni siquiera deberían leerse por un agente; si aparecen como parte del contexto de una tarea, la tarea debe detenerse y escalar, no continuar "ignorando" el archivo.

## Patrones de contenido denegados (`security.denied_content_patterns`)

- Claves de AWS: `AKIA[0-9A-Z]{16}`
- Bloques de clave privada: `-----BEGIN...PRIVATE KEY-----`
- Asignaciones sospechosas de secretos con valores largos: nombres de campo como `api_key`, `secret`, `token` o `password` seguidos de `=` y un valor extenso (ver expresiones exactas en `orchestrator.yaml`)

Estos patrones se verifican con `runtime/lib/security.sh` y se aplican automáticamente en el hook `post-agent-dispatch` (`runtime/hooks/post-agent-dispatch.sh`) sobre cualquier artefacto producido por un agente, y bajo demanda con `scripts/security-scan.sh`.

## Raíces escribibles

`security.writable_roots`: `agents/`, `.agents/skills`, `briefs/`, `contracts/`, `docs/`, `features/`, `hooks/`, `observability/`, `reports/`, `runtime/`, `schemas/`, `scripts/`, `skills/`, `templates/`, `workflows/` — más el propio código de la aplicación para los agentes implementadores, según `agent_permissions` por agente.

## Raíces totalmente prohibidas

`.git/` (a cualquier profundidad, incluido dentro de `repositories/<repo-name>/`) — ningún agente puede leer ni escribir aquí bajo ninguna circunstancia, ni siquiera `orchestrator`. `.codex/` y `.claude/` (directorios de tooling de los clientes de IA) ya no están prohibidos: son escribibles.

## Commits y push prohibidos para agentes

`git commit` y `git push` (incluido force-push y eliminación de ramas) están totalmente prohibidos para todo agente, en cualquier repositorio del monorepo (`tool_selection.default_denied -> git_commit_operations`). Los agentes dejan los cambios en el working tree sin commitear; revisar, commitear y publicar al remoto es responsabilidad manual exclusiva del usuario humano.

## Fallar cerrado

Cualquier hook que detecte una violación de seguridad (ruta prohibida, secreto detectado, permiso insuficiente) debe:

1. Detener inmediatamente la fase/workflow (no continuar "con precaución").
2. Registrar el evento en `observability/executions.jsonl` (`event_type: error`).
3. Marcar el error como no reintentable (`retry_policy.non_retryable_errors`), exigiendo intervención humana.

## Ver también

- `docs/worktree-strategy.md` — aislamiento adicional para trabajo paralelo/alto riesgo.
- `orchestrator.yaml -> security` — fuente de verdad de todos los patrones y raíces.
