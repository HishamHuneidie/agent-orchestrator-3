#!/usr/bin/env bash
# orchestrate.sh - Orquestación manual de soporte a partir de un feature-request.yaml
#
# Uso: scripts/orchestrate.sh <feature-request.yaml>
#
# Este script NO ejecuta agentes de IA (eso lo hace el cliente de IA activo
# siguiendo AGENTS.md). Lo que hace es: validar el feature-request contra su
# schema, derivar el feature_id, inicializar runtime/state/<feature-id>.yaml
# (vía el mismo hook que usa el flujo $feat) y dejar el repositorio listo para
# que el cliente de IA continúe la orquestación desde `intake`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../runtime/lib/common.sh
source "${ORCH_DIR}/runtime/lib/common.sh"
# shellcheck source=../runtime/lib/schema.sh
source "${ORCH_DIR}/runtime/lib/schema.sh"

request_file="${1:-}"
require_arg "feature-request.yaml" "$request_file"
[[ -f "$request_file" ]] || die "No existe el archivo: $request_file"

log_info "Validando ${request_file} contra schemas/feature-request.schema.yaml"
validate_yaml_against_schema "$request_file" "${ORCH_DIR}/schemas/feature-request.schema.yaml"

feature_name="$(python3 -c "import yaml,sys; print(yaml.safe_load(open(sys.argv[1]))['feature_name'])" "$request_file")"

log_info "Inicializando orquestación para '${feature_name}'"
"${ORCH_DIR}/runtime/hooks/pre-orchestration.sh" "$feature_name"

feature_id="$(to_feature_id "$feature_name")"
cat <<EOF

Feature-request validado y estado inicializado.

  feature_id: ${feature_id}
  estado:     runtime/state/${feature_id}.yaml

Siguiente paso: pide a tu cliente de IA que continúe la orquestación desde la
fase 'feature_analysis' (agents/feature-analyst.md), o usa el atajo \$feat F{num}
si prefieres partir de features/F{num}-{slug}/README.md en lugar de
este feature-request.yaml.
EOF
