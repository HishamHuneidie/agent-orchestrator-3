# Orchestrator

Sistema portable de orquestación de agentes de IA para convertir documentación de producto en features de software implementables.

El Orchestrator es un **control plane** basado en archivos, no una aplicación desplegable. No hay un runtime que ejecute agentes por sí solo: el cliente de IA activo (Codex, Claude Code, ...) carga [`AGENTS.md`](./AGENTS.md), las skills en [`./skills`](./skills) y el workflow correspondiente en [`./workflows`](./workflows), y ejecuta el ciclo completo siguiendo esos contratos.

```bash
./orchestrator validate   # valida la estructura del repositorio
./orchestrator bootstrap  # imprime instrucciones para el cliente de IA
```

## Cómo se organiza una feature

`orchestrator/` vive dentro de un monorepo. Las features **no** viven dentro de `orchestrator/`: viven en `features/`, en la **raíz del monorepo** (hermano de `orchestrator/`), nombradas `F{num}-{slug}`:

```text
features/F01-collaborative-lab/
├── README.md              # Documentación de producto. Autoría HUMANA. $feat solo lo LEE, nunca lo escribe.
├── P01-infra/              # Carpeta de fase. Generada/gestionada por $feat.
│   ├── T01-canal-tiempo-real.md
│   └── T02-resincronizacion.md
└── P02-ui-colaboracion/
    └── T01-ui-colaboracion.md
```

Cada fase es una **carpeta** `P{fase}-{slug}/`; cada tarea es un **archivo** `T{tarea}-{slug}.md` dentro de esa carpeta (sin repetir el prefijo de fase). El brief con el análisis/estimación de la feature se guarda internamente en `orchestrator/briefs/F{num}-{slug}/brief.yaml` (bookkeeping del orquestador, no forma parte de la carpeta de la feature).

1. **Tú** creas `features/F{num}-{slug}/README.md` con el alcance, criterios de aceptación, restricciones, riesgos y fuera de alcance de la feature.
2. Ejecutas `$feat F{num}` para que el Orchestrator la analice, estime y planifique (genera las carpetas de fase y sus tareas).
3. Ejecutas `$task F{num}-P{fase}` para implementar una fase concreta (con su revisión y pruebas). El código se escribe en `repositories/<repo-name>/`, no en `features/`.

## Uso rápido (atajos)

| Atajo | Qué hace |
|---|---|
| `$feat F{num}` | Localiza `features/F{num}-{slug}/README.md` (ya escrito por ti), analiza alcance/criterios/riesgos, estima y genera las carpetas `features/F{num}-{slug}/P{fase}-{slug}/` con sus tareas. **No implementa código.** |
| `$task F{num}-P{fase}` | Implementa todas las tareas de esa carpeta de fase (`P{fase}-{slug}/T*.md`), incluyendo su revisión y pruebas. |
| `implementa esta feature` | Ejecuta el workflow completo de punta a punta: intake → análisis → estimación → planificación → routing → implementación → revisión → pruebas → entrega. |

### Ejemplo completo

```bash
# 1. Escribes el alcance de la feature (relativo a la raíz del monorepo, no a orchestrator/)
mkdir -p ../features/F01-collaborative-lab
$EDITOR ../features/F01-collaborative-lab/README.md

# 2. Analizas y planificas (genera las carpetas de fase + tareas, sin código)
$feat F01

# 3. Implementas la fase P01 (implementación + revisión + pruebas)
$task F01-P01

# 4. Cuando esté lista la fase, implementas la siguiente
$task F01-P02
```

## Flujo principal

1. `$feat F{num}` → brief interno + carpetas de fase con tareas en `features/F{num}-{slug}/`, sin código.
2. `$task F{num}-P{fase}` → implementación de todas las tareas de esa fase, en `repositories/<repo-name>/`.
3. Revisión de código + pruebas unitarias, e2e y QA.
4. Cierre con resumen de entrega (`templates/delivery-summary.md`).

La resolución del selector `F{num}-P{fase}` (y, opcionalmente, `F{num}-P{fase}-T{tarea}` para una tarea concreta) la realiza [`scripts/resolve-feature-tasks.sh`](./scripts/resolve-feature-tasks.sh).

## Worktrees

Los worktrees de Git aíslan trabajo concurrente o de alto riesgo:

- **No usar**: documentación, estimación, tareas secuenciales pequeñas.
- **Obligatorio**: implementadores en paralelo.
- **Recomendado**: cambios grandes, migraciones, refactors de alto riesgo de conflicto.

```bash
scripts/create-worktree.sh <repo-name> <feature-id> <task-id>
scripts/cleanup-worktree.sh <repo-name> <feature-id> <task-id>
```

## Estructura

Ver [`ORCHESTRATOR-DOCUMENTATION.md`](../ORCHESTRATOR-DOCUMENTATION.md) para la descripción completa del árbol de directorios, o [`docs/architecture.md`](./docs/architecture.md) para el detalle arquitectónico.

```text
orchestrator/
├── agents/       # Contratos de comportamiento por perfil de agente
├── skills/       # Procedimientos reutilizables (SKILL.md)
├── workflows/    # Secuencias completas de trabajo con estado
├── hooks/        # Puntos de control documentales
├── schemas/      # Contratos YAML versionados
├── templates/    # Artefactos rellenables
├── runtime/      # Motor de soporte: CLI, hooks ejecutables, libs, estado
├── scripts/      # Validadores y utilidades operativas
├── docs/         # Documentación interna del propio sistema
├── observability/# Eventos/métricas en JSONL
├── briefs/       # Briefs generados por feature
├── reports/      # Evidencias de entrega por feature
└── contracts/    # Contratos ad-hoc (reservado)
```

## Seguridad

Mínimo privilegio explícito en [`orchestrator.yaml`](./orchestrator.yaml) y detallado en [`docs/security.md`](./docs/security.md): rutas y patrones de contenido denegados (secretos, tokens, claves privadas), raíces escribibles acotadas, y `.git/`/`.codex/` totalmente prohibidos. Los hooks fallan cerrado ante violaciones.

## Compatibilidad

Soporta contratos v1 (`execution-plan`, `agent-task` en YAML) junto al contrato v2 actual (planes/tareas en Markdown bajo `features/{feature_id}/`). Ver `orchestrator.yaml` → `supports_v1_contracts` y `legacy_scripts_supported`.
