# Workflow: review-and-test

Workflow especializado para las fases `review` y `test`, compartido por `application-feature.md` y `task-delivery.md`.

## Nodos

| Nodo | Agente | Hook | Artefacto de salida |
|---|---|---|---|
| `review` | code-reviewer | `hooks/pre-review.md` | `reports/<feature-id>/P*-review-report.md` |
| `unit_test` | unit-test-engineer | `hooks/pre-test.md` | sección unit de `reports/<feature-id>/P*-test-report.md` |
| `e2e_test` | e2e-test-engineer | `hooks/pre-test.md` | sección e2e de `reports/<feature-id>/P*-test-report.md` |
| `qa_verification` | qa-verifier | `hooks/pre-test.md` | veredicto QA en `reports/<feature-id>/P*-test-report.md` |

## Estados posibles

`pending`, `running`, `waiting`, `failed`, `cancelled`, `completed` (por nodo).

## Reglas de transición

1. `review` inicia en cuanto la tarea/fase de `implementation` está `completed`.
2. `unit_test`, `e2e_test` y `qa_verification` pueden ejecutarse en paralelo entre sí (no compiten por el mismo recurso), pero cada uno requiere que `implementation` esté `completed`; no dependen entre sí ni de `review` para iniciar.
3. Si `review` reporta hallazgos bloqueantes, el nodo padre de `implementation` vuelve a `pending` y este workflow se reinicia para esa tarea tras la corrección.
4. Si cualquiera de `unit_test`/`e2e_test`/`qa_verification` reporta un criterio de aceptación no cumplido, se marca como hallazgo bloqueante equivalente al de `review`.
5. El conjunto de nodos de este workflow se considera `completed` solo cuando `review` + los tres nodos de test están `completed` sin hallazgos bloqueantes pendientes.

## Paralelismo

`review` respeta `parallelism.max_parallel_reviewers` (2). Los tres nodos de test no tienen límite propio explícito, pero comparten el límite global de `time_policy`/`cost_policy` por tarea.

## Persistencia de estado

El resultado consolidado (hallazgos, veredictos, reintentos) se persiste tanto en `runtime/state/<feature-id>.yaml` (para control de flujo) como en los reportes Markdown bajo `reports/<feature-id>/` (para consumo humano y para `delivery-summary.md`).
