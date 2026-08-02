# Diagrama: flujo de ejecución (fases del workflow)

```mermaid
stateDiagram-v2
    [*] --> intake
    intake --> feature_analysis
    feature_analysis --> estimation
    estimation --> planning
    planning --> routing
    routing --> implementation

    implementation --> review
    review --> test
    test --> delivery: sin hallazgos bloqueantes
    test --> implementation: hallazgos bloqueantes
    review --> implementation: hallazgos bloqueantes

    delivery --> [*]: completed

    intake --> failed: error no reintentable
    feature_analysis --> failed: documentacion fuente ausente
    implementation --> failed: reintentos agotados
    failed --> [*]
```

Cada nodo puede estar, en cualquier momento, en uno de: `pending`, `running`, `waiting`, `failed`, `cancelled`, `completed` (ver `docs/workflow-engine.md`). Este diagrama muestra únicamente las transiciones de **fase a fase** en el camino feliz y los principales caminos de fallo/retrabajo.
