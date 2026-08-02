#!/usr/bin/env bash
# pre-orchestration.sh - Contraparte ejecutable de hooks/pre-orchestration.md
#
# Uso: pre-orchestration.sh <feature_name>
# Verifica estructura del repo y prepara/valida runtime/state/<feature-id>.yaml.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/observability.sh
source "${SCRIPT_DIR}/../lib/observability.sh"

feature_name="${1:-}"
require_arg "feature_name" "$feature_name"

feature_id="$(to_feature_id "$feature_name")"
state_file="${ORCH_ROOT}/runtime/state/${feature_id}.yaml"

log_info "pre-orchestration: validando estructura del repositorio"
if ! "${ORCH_ROOT}/scripts/validate-structure.sh" >/tmp/validate-structure.out 2>&1; then
  cat /tmp/validate-structure.out >&2
  log_error_event "$feature_id" "intake" "estructura del repositorio invalida"
  die "La estructura del repositorio no es valida. Ver detalle arriba."
fi

ensure_dir "${ORCH_ROOT}/runtime/state"

if [[ -f "$state_file" ]]; then
  log_info "Estado previo encontrado para '${feature_id}', se reanudará el workflow."
else
  log_info "Creando estado inicial para '${feature_id}'."
  cat > "$state_file" <<EOF
feature_id: ${feature_id}
feature_name: "${feature_name}"
created_at: "$(timestamp_utc)"
updated_at: "$(timestamp_utc)"
status: running
current_phase: intake
phases:
  intake: {status: running}
  feature_analysis: {status: pending}
  estimation: {status: pending}
  planning: {status: pending}
  routing: {status: pending}
  implementation: {status: pending}
  review: {status: pending}
  test: {status: pending}
  delivery: {status: pending}
EOF
fi

log_event "hook" "$feature_id" "intake" "ok" "pre-orchestration completado"
log_info "pre-orchestration OK para '${feature_id}'."
