# Skill: feature-from-docs

## Trigger

Se activa cuando `feature-analyst` necesita extraer una feature analizable a partir de documentación de producto en `docs/`.

## Parameters

- `feature_name` (obligatorio): identificador de la feature, usado para localizar `features/F{num}-{slug}/README.md`.

## Inputs

- `features/F{num}-{slug}/README.md`.
- `schemas/brief.schema.yaml`, `templates/brief.yaml`.

## Procedure

1. Leer la documentación completa de la feature.
2. Extraer explícitamente:
   - Alcance (qué se va a construir).
   - Criterios de aceptación (verificables, en forma de lista).
   - Restricciones (técnicas, de negocio, de tiempo).
   - Riesgos.
   - Fuera de alcance (qué NO se va a construir).
3. Marcar cualquier ambigüedad o información faltante como pendiente de definición, sin rellenarla con suposiciones.
4. Rellenar `templates/brief.yaml` con la información extraída.
5. Validar el brief resultante contra `schemas/brief.schema.yaml`.
6. Guardar en `briefs/<feature-id>/brief.yaml`.

## Expected Result

Un brief estructurado y validado, fiel a la documentación fuente, sin alcance inventado.

## Quality Gates

- Cada criterio de aceptación es verificable (se puede comprobar objetivamente si se cumple o no).
- Ninguna ambigüedad de la documentación fuente fue resuelta por suposición sin marcarla explícitamente.
- El brief valida contra su schema.
