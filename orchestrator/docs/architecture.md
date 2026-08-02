# Arquitectura: control plane basado en archivos

## Idea central

El Orchestrator no es un servicio que corre en segundo plano ni un runtime independiente: es un **conjunto de archivos** (Markdown para contratos de comportamiento, YAML para configuración/datos, Bash para validación) que un cliente de IA ya activo (Codex, Claude Code, ...) interpreta y ejecuta directamente. No hay un proceso "orchestrator-daemon"; el propio cliente de IA es el runtime.

```
┌─────────────────────────────┐
│   Cliente de IA activo      │  <- el "runtime" real
│ (Codex / Claude Code / ...) │
└──────────────┬───────────────┘
               │ lee/escribe
               v
┌─────────────────────────────────────────────┐
│              /orchestrator                  │
│  AGENTS.md, orchestrator.yaml                │
│  agents/  skills/  workflows/  hooks/        │
│  schemas/ templates/ runtime/ scripts/       │
│  docs/    observability/ briefs/ reports/    │
└─────────────────────────────────────────────┘
```

## Por qué archivos y no un servicio

- **Auditable**: todo el comportamiento (qué puede leer/escribir un agente, qué modelo usar, qué constituye un quality gate) está en texto plano versionado junto al código.
- **Portable**: cualquier cliente de IA que sepa leer Markdown/YAML y ejecutar Bash puede orquestar features siguiendo el mismo contrato, sin integraciones específicas.
- **Sin infraestructura adicional**: no requiere desplegar, monitorizar ni parchear un servicio propio; el "runtime" ya existe (el cliente de IA que el usuario está usando).

## Las tres capas de contrato

1. **Markdown** (`agents/`, `skills/`, `workflows/`, `hooks/`, `docs/`): comportamiento — qué debe hacer cada agente/skill/workflow, legible por humanos y por el cliente de IA sin transformación.
2. **YAML** (`orchestrator.yaml`, `schemas/`, `templates/*.yaml`): configuración y forma de los datos — versionado, diffable, validable estructuralmente.
3. **Shell** (`scripts/`, `runtime/`): la única capa "ejecutable" en sentido tradicional — valida estructura, escanea seguridad, gestiona worktrees. Nunca decide *qué* hacer, solo verifica *que se hizo correctamente*.

## Flujo de una feature en esta arquitectura

Ver `docs/agent-lifecycle.md` para el detalle por agente y `docs/workflow-engine.md` para la semántica de estados. En resumen: el cliente de IA carga `AGENTS.md`, identifica el atajo invocado, carga la skill y el workflow correspondientes, y por cada nodo del workflow adopta el contrato del agente indicado en `agents/`, ejecutando los hooks antes/después de cada fase.

## Ver también

- `docs/architecture-refactor-report.md` — informe de la evolución hacia esta arquitectura "profesional".
- `docs/ai-client-orchestration.md` — cómo específicamente el cliente de IA ejecuta la orquestación.
