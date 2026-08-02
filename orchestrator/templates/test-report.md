<!--
Template: test-report.md
Usado por unit-test-engineer, e2e-test-engineer y qa-verifier para producir
reports/<feature-id>/P{fase}-test-report.md (consolidado entre los tres).
El front-matter YAML debe validar contra schemas/test-report.schema.yaml
-->

---
feature_id: "{feature_id}"
phase_id: "{phase_id}"
unit:
  status: "pass"     # pass | fail
  cases_run: 0
  cases_failed: 0
e2e:
  status: "pass"      # pass | fail
  flows_covered: []
qa:
  status: "pass"       # pass | fail | partial
  acceptance_criteria_verdicts: []
blocking_findings: []
---

# Reporte de pruebas — {feature_id} / {phase_id}

## Pruebas unitarias

- Estado: {pass|fail}
- Casos ejecutados: {n} — Fallidos: {n}
- Evidencia: {resumen de salida de la suite}

## Pruebas end-to-end

- Estado: {pass|fail}
- Flujos críticos cubiertos: {lista}
- Evidencia: {resumen de ejecución real}

## Verificación QA

| Criterio de aceptación | Veredicto | Evidencia |
|---|---|---|
| {criterio 1} | cumple / no cumple / parcial | {cómo se verificó} |

## Hallazgos bloqueantes

- {descripción, si los hay; "Ninguno" si no aplica}
