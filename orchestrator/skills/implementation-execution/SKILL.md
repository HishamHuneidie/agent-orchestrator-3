# Skill: implementation-execution

## Trigger

Se activa cuando un agente implementador (`backend-engineer`, `frontend-engineer`, `fullstack-engineer`) recibe una tarea concreta para implementar.

## Parameters

- `task_ref` (obligatorio): referencia a la tarea (`features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-*.md`).
- `use_worktree` (opcional, booleano): si la tarea está marcada como paralela/alto riesgo, forzar el uso de worktree.

## Inputs

- El archivo de tarea completo (criterios de aceptación, restricciones, fuera de alcance).
- `briefs/<feature-id>/brief.yaml` (contexto de producto, opcional).
- Código existente relevante.

## Procedure

1. Leer la tarea completa, incluyendo qué está explícitamente fuera de alcance.
2. Si `use_worktree` es verdadero (o la tarea lo indica), crear el worktree con `scripts/create-worktree.sh <repo-name> <feature-id> <task-id>` (dentro del repositorio indicado en la tarea) antes de tocar cualquier archivo.
3. Explorar el código existente relevante para seguir sus convenciones (no introducir un patrón nuevo sin necesidad).
4. Implementar el cambio mínimo necesario para satisfacer cada criterio de aceptación.
5. Ejecutar los comandos de validación indicados en la tarea (build/lint/tests).
6. Si la tarea es de frontend o toca UI, verificar visualmente en un dev server real (ver `run` skill/skill equivalente del proyecto) antes de dar por completada la tarea.
7. Marcar la tarea como lista para revisión (actualizar su estado según la convención de `templates/feature-task.md`).
8. Si se usó worktree y el trabajo está listo para integrarse, coordinar con `orchestrator` antes de limpiar (`scripts/cleanup-worktree.sh`).

## Expected Result

El código que satisface la tarea está implementado, validado localmente, y listo para pasar a `review`/`test`.

## Quality Gates

- El alcance implementado coincide exactamente con la tarea; nada de lo marcado como fuera de alcance fue tocado.
- Los comandos de validación de la tarea se ejecutaron y pasaron.
- Ningún secreto o credencial fue introducido (ver `orchestrator.yaml -> security.denied_content_patterns`).
- Si la tarea requería worktree, se usó; si no, no se creó uno innecesariamente.
