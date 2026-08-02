# Cómo se construyen los prompts para cada agente

## Plantilla base

Todo prompt efectivo entregado a un agente se construye a partir de `templates/prompt.md`, siguiendo las secciones declaradas en `orchestrator.yaml -> prompt_builder.sections`:

1. **role** — qué agente es (`agents/<agent>.md` completo como contrato de comportamiento).
2. **context** — feature, fase actual, ruta del brief y de cualquier contexto adicional específico de la fase.
3. **inputs** — rutas y resumen de cada input obligatorio para esa fase/tarea.
4. **constraints** — alcance exacto, fuera de alcance, y permisos de lectura/escritura aplicables (`orchestrator.yaml -> agent_permissions`).
5. **expected_output** — artefacto esperado, su ruta exacta y el schema contra el que debe validar.
6. **quality_gates** — el subconjunto del checklist de calidad del agente relevante para esa unidad de trabajo.

## Briefs especializados

Para las fases de implementación y revisión/pruebas, el prompt se enriquece con un brief especializado (no reemplaza al brief general, lo complementa):

- `templates/backend-brief.yaml` para `backend-engineer`.
- `templates/frontend-brief.yaml` para `frontend-engineer`.
- `templates/qa-brief.yaml` para la fase `test`.
- `templates/review-brief.yaml` para la fase `review`.

Estos briefs especializados se generan a partir del brief general (`briefs/<feature-id>/brief.yaml`) y de la tarea concreta (`features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-*.md`), extrayendo solo lo relevante para ese agente (p. ej. `backend-brief.yaml` no incluye detalles de UI).

## Ejemplos generados

`runtime/prompts/<feature-id>/` contiene, por feature, los prompts ya construidos como referencia histórica (por ejemplo `runtime/prompts/sample-feature/feature-analyst.md`). Estos archivos documentan cómo se vio un prompt real; no son reconsumidos automáticamente en ejecuciones futuras.

## Por qué esta estructura

Mantener el prompt builder basado en una plantilla + secciones fijas (en vez de prompts ad-hoc por agente) asegura que:

- Todo agente recibe explícitamente sus restricciones de permisos, no solo su tarea.
- Es auditable qué información exacta recibió un agente en una ejecución dada (queda en `runtime/prompts/`).
- Añadir un nuevo agente solo requiere su contrato en `agents/` y, si aplica, un brief especializado nuevo en `templates/`, sin tocar la lógica del prompt builder en sí.

Ver también `docs/diagrams/prompt-builder.md` para el diagrama de flujo de construcción.
