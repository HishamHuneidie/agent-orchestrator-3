<!--
Template: delivery-summary.md
Usado por delivery-summarizer para producir reports/<feature-id>/P{fase}-delivery-summary.md
El front-matter YAML debe validar contra schemas/delivery-summary.schema.yaml
-->

---
feature_id: "{feature_id}"
phase_id: "{phase_id}"
delivered_at: "{fecha ISO-8601}"
known_pending_items: []
---

# Resumen de entrega — {feature_id} / {phase_id}

## Qué se pidió

{resumen del alcance original, tomado del brief}

## Qué se entregó

{resumen del alcance realmente implementado}

## Revisión de código

{resumen del reporte de revisión: hallazgos resueltos, deuda técnica aceptada si la hay}

## Pruebas

{resumen del reporte de pruebas: unit/e2e/QA, estado final}

## Pendientes conocidos

- {pendiente 1, si lo hay; "Ninguno" si no aplica}

## Referencias

- Brief: `briefs/{feature_id}/brief.yaml`
- Plan: `features/{feature_id}/README.md`
- Revisión: `reports/{feature_id}/{phase_id}-review-report.md`
- Pruebas: `reports/{feature_id}/{phase_id}-test-report.md`
