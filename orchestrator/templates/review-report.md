<!--
Template: review-report.md
Usado por code-reviewer para producir reports/<feature-id>/P{fase}-review-report.md
El front-matter YAML debe validar contra schemas/review-report.schema.yaml
-->

---
feature_id: "{feature_id}"
phase_id: "{phase_id}"
reviewed_by: "code-reviewer"
verdict: "changes_requested"   # approved | changes_requested
---

# Reporte de revisión — {feature_id} / {phase_id}

## Veredicto

{approved | changes_requested} — {una frase resumen}

## Criterios de aceptación contrastados

- [x] {criterio 1} — cumple
- [ ] {criterio 2} — no cumple: {detalle}

## Hallazgos

### Bloqueantes

- **{archivo}:{línea}** — {descripción del problema y por qué bloquea}

### Importantes

- **{archivo}:{línea}** — {descripción}

### Menores

- **{archivo}:{línea}** — {descripción}

## Notas adicionales

{observaciones que no son hallazgos accionables pero dan contexto}
