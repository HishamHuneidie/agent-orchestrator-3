# Workflow: documentation-generation

## Propósito

Generar o actualizar documentación fuente de producto en `features/F{num}-{slug}/README.md` a partir de `docs/**`, sin
crear fases, tareas ni código de aplicación.

## Trigger

`$docu`

## Agente

`documentation-analyst`

## Permisos

Puede leer:

- `docs/**`
- `features/**`
- `AGENTS.md`
- `orchestrator/AGENTS.md`
- `orchestrator/orchestrator.yaml`
- `orchestrator/skills/**`
- `orchestrator/workflows/**`
- `orchestrator/templates/**`
- `orchestrator/schemas/**`

Puede escribir únicamente:

- `features/F*/README.md`

No puede escribir:

- `features/F*/P*/**`
- `repositories/**`
- `orchestrator/README.md`
- `orchestrator/briefs/**`
- `orchestrator/reports/**`
- `orchestrator/runtime/**`
- configuración, schemas, hooks, workflows, skills ni contratos del orquestador

## Estados

```text
inventory -> analysis -> proposal -> waiting_for_approval -> materialization -> completed
```

## Procedimiento

1. Cargar `orchestrator/agents/documentation-analyst.md` y `orchestrator/skills/docu/SKILL.md`.
2. Inventariar la documentación fuente en `docs/**`.
3. Inventariar las features existentes en `features/**`, preservando numeración, slugs y contenido existente.
4. Analizar cobertura, duplicados, solapamientos, dependencias, huecos y contradicciones.
5. Presentar al usuario una propuesta antes de escribir:
   - features nuevas a crear;
   - features existentes a actualizar;
   - motivo de cada cambio;
   - paths afectados;
   - resumen de contenido o diff previsto;
   - ambigüedades pendientes.
6. Detenerse en `waiting_for_approval` hasta recibir aprobación explícita del usuario.
7. Materializar únicamente los `features/F*/README.md` aprobados.
8. Verificar que no se tocaron rutas fuera de `features/F*/README.md`.
9. Entregar resumen final con archivos creados, archivos modificados, ambigüedades pendientes y comandos `$feat F{num}` sugeridos.

## Reglas estrictas

- No elimina, renumera, fusiona ni sobrescribe features existentes sin aprobación explícita.
- No genera carpetas `P{fase}-{slug}/`.
- No genera archivos `T{tarea}-{slug}.md`.
- No modifica `repositories/**`.
- No ejecuta `$feat` ni `$task`.
- No inventa decisiones de producto no respaldadas por `docs/**`; las marca como ambigüedad, riesgo o pendiente.
