# Skill: documentation-generation

## Trigger

Se activa con el atajo `$docu`.

## Propósito

Analizar `docs/**` y `features/**` para proponer, crear o actualizar documentación fuente de producto en
`features/F{num}-{slug}/README.md`.

Esta skill no implementa código, no genera fases y no genera tareas.

## Inputs

- `docs/**` como documentación funcional y técnica de la aplicación.
- `features/**` para inventariar features existentes, numeración, solapamientos y gaps.
- `orchestrator/agents/documentation-analyst.md`.
- `orchestrator/workflows/documentation-generation.md`.

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

## Procedimiento

1. Cargar el contrato `documentation-analyst`.
2. Inventariar `docs/**`.
3. Inventariar `features/**`, conservando numeración existente.
4. Comparar documentación fuente contra features existentes.
5. Presentar una propuesta antes de escribir:
   - features nuevas;
   - features existentes a actualizar;
   - motivo de cada cambio;
   - paths afectados;
   - contenido resumido o diff previsto;
   - ambigüedades pendientes.
6. Esperar aprobación explícita del usuario.
7. Materializar únicamente los `features/F*/README.md` aprobados.
8. Verificar que no se tocaron rutas fuera de `features/F*/README.md`.

## Restricciones

- No elimina, renumera, fusiona ni sobrescribe features existentes sin aprobación explícita.
- No crea carpetas de fase `features/F*/P*/`.
- No crea tareas `features/F*/P*/T*.md`.
- No modifica `repositories/**`.
- No escribe briefs, reportes ni estado runtime del orquestador.
- No ejecuta `$feat` ni `$task`.
- No inventa decisiones de producto no respaldadas por `docs/**`; las marca como ambigüedad, riesgo o pendiente.

## Resultado esperado

Uno o más `features/F{num}-{slug}/README.md` aprobados, completos y listos para que `$feat F{num}` genere fases y tareas
sin reinterpretar el alcance.
