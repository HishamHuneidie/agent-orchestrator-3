# Skill: estimation

## Trigger

Se activa cuando `estimator` necesita producir una estimación de complejidad/dependencias/tiempo a partir de un brief.

## Parameters

- `feature_id` (obligatorio): identifica el brief de entrada en `briefs/<feature-id>/brief.yaml`.

## Inputs

- `briefs/<feature-id>/brief.yaml`.
- Historial de `reports/` de features similares ya entregadas (para calibrar, si existe).

## Procedure

1. Leer el brief completo.
2. Descomponer el trabajo esperado en áreas: backend, frontend, fullstack, tests, documentación.
3. Para cada área, estimar:
   - Complejidad (baja/media/alta) con justificación breve.
   - Tiempo estimado (rango, no un único número).
   - Nivel de confianza (alta/media/baja) según cuánta información comparable existe.
4. Identificar dependencias externas (servicios, equipos, features previas) que puedan bloquear el trabajo.
5. Guardar el resultado en `briefs/<feature-id>/estimate.yaml`.

## Expected Result

Una estimación desglosada por área, con rangos de tiempo, dependencias y nivel de confianza explícito, lista para que `implementation-planner` la use.

## Quality Gates

- La estimación está desglosada por área, no es un único número global.
- Toda dependencia externa relevante está explícita.
- El nivel de confianza refleja honestamente cuánta evidencia comparable existe.
