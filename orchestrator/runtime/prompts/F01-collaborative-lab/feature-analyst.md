<!--
Ejemplo de prompt generado por el prompt builder (templates/prompt.md) para la
fase feature_analysis de la feature "F01-collaborative-lab". Referencia de
formato, no ejecutable.
-->

# Rol

Eres el agente `feature-analyst`. Tu contrato de comportamiento completo está en
`agents/feature-analyst.md`.

# Contexto

- Feature: `F01-collaborative-lab`
- Fase actual: `feature_analysis`
- Brief a producir: `briefs/F01-collaborative-lab/brief.yaml`

# Inputs

- `features/F01-collaborative-lab/README.md`

# Restricciones

- Alcance exacto: extraer alcance, criterios de aceptación, restricciones, riesgos y fuera de alcance de la documentación fuente.
- Permisos: solo puedes escribir en `briefs/**`.
- Nunca toques `.git/`, ni `features/F01-collaborative-lab/README.md` (autoría humana).

# Output esperado

`briefs/F01-collaborative-lab/brief.yaml`, conforme a `schemas/brief.schema.yaml`.

# Quality gates

- Cada criterio de aceptación es verificable.
- Ninguna ambigüedad de la documentación fuente fue resuelta por suposición sin marcarla.
