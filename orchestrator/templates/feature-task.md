<!--
Template: feature-task.md
Usado por implementation-planner para generar cada
features/{feature_id}/P{fase}-{slug}/T{tarea}-{slug}.md
(features/ vive en la raíz del monorepo, hermano de orchestrator/)
Convención de nombre de archivo: T{tarea de 2 dígitos}-{slug-kebab}.md
dentro de la carpeta de fase P{fase de 2 dígitos}-{slug}/
-->

# T{tarea}: {título breve de la tarea}

- **feature_id**: `{feature_id}`
- **phase_id**: `P{fase}`
- **task_id**: `T{tarea}` <!-- único dentro de la carpeta de fase; el identificador completo para $task es F{num}-P{fase}-T{tarea} -->
- **Estado**: pending <!-- pending | in_progress | in_review | in_test | completed | blocked -->
- **Agente asignado**: {backend-engineer | frontend-engineer | fullstack-engineer}
- **Repositorio**: `repositories/{repo-name}` <!-- dónde se escribe el código de esta tarea -->
- **Depende de**: {lista de task_id, o "—"}
- **Worktree**: {required | recommended | not-needed}

## Descripción

{qué hay que construir, en 2-4 frases, suficiente para implementar sin releer todo el brief}

## Criterios de aceptación

- [ ] {criterio verificable 1}
- [ ] {criterio verificable 2}

## Fuera de alcance (de esta tarea)

- {qué NO debe tocarse en esta tarea, aunque esté relacionado}

## Contexto técnico

- Archivos/módulos relevantes: {rutas}
- Convenciones a seguir: {patrón existente a replicar, si aplica}

## Comandos de validación

```bash
{comando de build/lint/test que debe pasar antes de marcar la tarea como lista}
```

## Notas

{cualquier restricción o decisión no obvia que el implementador deba conocer}

---
_Actualizado por última vez: {fecha}_
