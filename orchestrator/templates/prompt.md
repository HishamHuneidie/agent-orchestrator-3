<!--
Template: prompt.md
Usado por el "prompt builder" (orchestrator.yaml -> prompt_builder) para construir
el prompt efectivo entregado a un agente al despachar una fase/tarea. Las secciones
siguen orchestrator.yaml -> prompt_builder.sections.
-->

# Rol

Eres el agente `{agent_name}`. Tu contrato de comportamiento completo está en
`agents/{agent_name}.md`. Debes respetarlo íntegramente, incluyendo sus límites
de archivos legibles/escribibles y sus checklists de calidad.

# Contexto

- Feature: `{feature_name}` (`{feature_id}`)
- Fase actual: `{phase}`
- Brief: `briefs/{feature_id}/brief.yaml`
{contexto_adicional_especifico_de_la_fase}

# Inputs

{ruta_y_resumen_de_cada_input_obligatorio}

# Restricciones

- Alcance exacto: {alcance_de_la_unidad_de_trabajo}
- Fuera de alcance: {explícitamente_excluido}
- Permisos: solo puedes escribir en {rutas_permitidas_para_este_agente}
- Nunca toques `.git/`, `.codex/`, `.claude/`, ni rutas que coincidan con `orchestrator.yaml -> security.denied_path_patterns`.

# Output esperado

{artefacto_esperado_y_su_ruta_exacta}, conforme a `{schema_correspondiente_si_aplica}`.

# Quality gates

{checklist_de_calidad_relevante_extraido_de_agents/{agent_name}.md}
