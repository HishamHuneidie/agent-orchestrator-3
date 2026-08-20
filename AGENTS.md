# AGENTS.md

Punto de entrada para cualquier cliente de IA (Codex, Claude Code, ...) que trabaje en este monorepo. Léelo antes de tocar nada.

## Qué es este repositorio

Un monorepo que combina:

- **`orchestrator/`** — el control plane de orquestación de agentes de IA. Contiene el contrato operativo completo (agentes, skills, workflows, hooks, scripts) que rige cómo se analizan, planifican, implementan, revisan y entregan las features.
- **`features/`** — el trabajo en curso: una carpeta por feature (`F{num}-{slug}/`), con su documentación de producto y su plan de fases/tareas.
- **`repositories/`** — el código real de la(s) aplicación(es) sobre las que trabajan los agentes implementadores, una carpeta por repo (`repo-name-1/`, `repo-name-2/`, ...).
- **`docs/`** — documentación funcional y técnica de la aplicación (no del orquestador; esa vive en `orchestrator/docs/`).
- **`scripts/`** — utilidades sh/bash de uso general del monorepo (build, arranque, mantenimiento). Los scripts propios del orquestador viven en `orchestrator/scripts/`.
- **`Makefile`** / **`compose.yaml`** — arranque y orquestación local de los repos bajo `repositories/` (cada uno con su propio `.docker/`).

## Contrato operativo completo

**La guía operativa detallada — atajos, permisos, ciclo de vida de una feature, seguridad — vive en [`orchestrator/AGENTS.md`](./orchestrator/AGENTS.md). Cárgala siempre antes de ejecutar `$feat` o `$task`.**

## Regla rápida: dónde vive cada cosa

| Qué | Dónde |
|---|---|
| Documentación de producto de una feature (autoría humana) | `features/F{num}-{slug}/README.md` |
| Fases de una feature | `features/F{num}-{slug}/P{fase}-{slug}/` (carpetas) |
| Tareas de una fase | `features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-{slug}.md` |
| Código de la aplicación | `repositories/<repo-name>/**` |
| Contratos/config del orquestador | `orchestrator/**` (agents, skills, workflows, schemas, orchestrator.yaml) |
| Briefs, reportes y estado de ejecución (bookkeeping interno) | `orchestrator/briefs/`, `orchestrator/reports/`, `orchestrator/runtime/state/` |

## Atajos

- `$feat F{num}` → analiza `features/F{num}-{slug}/README.md`, genera las carpetas de fase y sus tareas. No implementa código.
- `$task F{num}-P{fase}` → implementa todas las tareas de esa carpeta de fase (código en `repositories/**`, revisión y pruebas incluidas).
- `$docu` → analiza la carpeta docs, genera las diferentes features que serán desarrolladas más adelante por la instrucción `$feat ***`. No implementa código. La revisión es exhaustiva para que las diferentes features permitan crear una app completamente funcional con todos los componentes que una app completa amerita.

Ver `orchestrator/AGENTS.md` para el detalle completo de cada fase, permisos y quality gates.

## Inicialización

Cuando se escriban comandos que hablen de inicializar el orquestador, se debe ejecutar un prompt específico.

Ejemplos de instrucciones de inicialización del orquestador:
- inicia el orquestador
- orch-init
- inicializa el orquestador
- carga los componentes del orquestador
- load orchestrator

El prompt específico que se debe ejecutar es el siguiente:

```markdown
Revisa a fondo la carpeta `orchestrator` y entiende la finalidad de cada uno de sus componentes.

Tu objetivo es utilizar toda la información disponible en `orchestrator` para configurar correctamente Codex dentro de este proyecto, creando y organizando los archivos necesarios en `.codex/`, incluyendo `.codex/agents/` y cualquier otra subcarpeta que sea necesaria.

Dentro de `orchestrator` encontrarás distintos tipos de componentes, por ejemplo:

* `agents/`: definición y documentación de los subagentes.
* `skills/`: definición de skills.
* `workflows/`: workflows y procesos de trabajo.
* `hooks/`: hooks y automatizaciones.
* Otros componentes o configuraciones relevantes que deberás identificar durante el análisis.

Es importante entender que los archivos dentro de `orchestrator` describen cómo debe funcionar cada componente, pero no necesariamente representan el archivo final que Codex necesita. Debes interpretar esa documentación y, basándote en ella, crear dentro de `.codex/` los archivos reales necesarios para que Codex pueda utilizar esos componentes correctamente.

Puedes crear archivos en el formato que corresponda según las capacidades y convenciones actuales de Codex (`.md`, `.toml`, `.yaml`, `.ts`, etc.). No copies estructuras o formatos de forma mecánica: adapta cada componente al formato que Codex realmente necesite.

Evita duplicar configuraciones o crear archivos redundantes. Si varios documentos describen partes de una misma configuración, consolídalos cuando tenga sentido.

El resultado final debe dejar `.codex/` completamente configurado para que todos los componentes relevantes definidos en `orchestrator` puedan utilizarse tanto en esta sesión como en futuras sesiones de Codex dentro de este proyecto.

Todo debe quedar contenido dentro de este proyecto, `mini-video-factory`. No realices configuraciones globales fuera del proyecto.
```

---

