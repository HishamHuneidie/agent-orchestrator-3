# Informe: hacia una arquitectura "profesional" del Orchestrator

> Referenciado desde `README.md`. Documenta las decisiones de diseño que llevaron a la forma actual del control plane.

## Motivación

Un sistema de orquestación de agentes de IA para desarrollo de software necesita ser, simultáneamente:

- **Legible por humanos**, para que el equipo pueda auditar y ajustar el comportamiento sin escribir código.
- **Legible por IA**, para que cualquier cliente (Codex, Claude Code, futuros clientes) pueda interpretarlo sin un parser propietario.
- **Seguro por defecto**, dado que los agentes tienen acceso de lectura/escritura a un repositorio real.
- **Portable**, sin atarse a la API o SDK de un proveedor de modelos concreto.

## Decisiones clave

1. **Sin runtime propio.** Se descartó construir un servicio/daemon que despache agentes vía API, porque duplicaría capacidades que el cliente de IA activo ya tiene (razonamiento, uso de herramientas, gestión de contexto) y añadiría una superficie de fallo y mantenimiento adicional. En su lugar, el cliente de IA *es* el runtime, guiado por `AGENTS.md`.
2. **Markdown como contrato de comportamiento.** Los contratos de agentes (`agents/*.md`) y skills (`skills/*/SKILL.md`) siguen una estructura fija y verificable (`scripts/validate-structure.sh`), de forma que un cambio de comportamiento es un diff de texto revisable en PR, no un cambio de código.
3. **YAML como contrato de datos.** Todo artefacto que fluye entre agentes (brief, plan, reportes) tiene un schema en `schemas/` y se valida con `scripts/validate-contract.sh`, evitando que un agente produzca un artefacto que el siguiente no pueda consumir.
4. **Separación entre plan y código.** `$feat` nunca escribe código; solo `$task` lo hace. Esto permite revisar el plan de una feature completa (fases, tareas, estimaciones) antes de gastar tiempo/coste de implementación.
5. **Seguridad como hook, no como convención.** Las reglas de `orchestrator.yaml -> security` se aplican mediante hooks ejecutables (`runtime/hooks/*.sh`) que fallan cerrado, en vez de depender de que cada agente "recuerde" no tocar secretos.
6. **Compatibilidad hacia atrás explícita.** Los contratos v1 (`execution-plan`, `agent-task` en YAML) se mantienen soportados (`supports_v1_contracts: true`) mientras coexisten con el modelo v2 (planes/tareas en Markdown bajo `features/`), para no romper integraciones o scripts existentes durante la migración.

## Resultado

Un control plane sin dependencias de infraestructura, completamente auditable en Git, que cualquier cliente de IA compatible con Markdown/YAML/Bash puede ejecutar sin cambios.
