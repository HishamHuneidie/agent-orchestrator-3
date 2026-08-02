# Hook: pre-orchestration

## Propósito

Se ejecuta antes de iniciar la orquestación de una feature (nodo `intake`). Verifica que el repositorio y el entorno están en condiciones de aceptar una nueva orquestación o de reanudar una existente.

## Cuándo se ejecuta

Al recibir cualquiera de los atajos (`$feat`, `$task`, "implementa esta feature"), antes de crear o cargar `runtime/state/<feature-id>.yaml`.

## Inputs

- `feature_name` (o `feature-id` derivado de él).
- Estructura del repositorio (validada contra `scripts/validate-structure.sh`).

## Outputs

- Confirmación de que es seguro proceder, o un error explícito que detiene el flujo.
- Si no existe estado previo, se crea el esqueleto inicial de `runtime/state/<feature-id>.yaml`.

## Errores posibles

- Estructura del repositorio inválida (falta algún directorio/archivo esperado por `scripts/validate-structure.sh`).
- `feature-id` inválido o con caracteres no permitidos para un nombre de directorio/estado.
- Estado previo corrupto o que no valida contra `schemas/workflow-state.schema.yaml`.

## Componente ejecutable correspondiente

`runtime/hooks/pre-orchestration.sh`
