#!/usr/bin/env bash
# post-delivery.sh - Contraparte ejecutable de hooks/post-delivery.md
#
# Uso: post-delivery.sh <feature_id> <delivery_summary_file>
# Verifica que el resumen de entrega existe, marca el estado como completado
# y limpia worktrees ya integrados.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/observability.sh
source "${SCRIPT_DIR}/../lib/observability.sh"

feature_id="${1:-}"; summary_file="${2:-}"
require_arg "feature_id" "$feature_id"
require_arg "delivery_summary_file" "$summary_file"

if [[ ! -f "$summary_file" ]]; then
  log_error_event "$feature_id" "delivery" "resumen de entrega no encontrado: $summary_file"
  die "No se encontró el resumen de entrega: $summary_file"
fi

state_file="${ORCH_ROOT}/runtime/state/${feature_id}.yaml"
if [[ -f "$state_file" ]]; then
  tmp_file="$(mktemp)"
  awk -v ts="$(timestamp_utc)" '
    /^status:/ { print "status: completed"; next }
    /^updated_at:/ { print "updated_at: \"" ts "\""; next }
    { print }
  ' "$state_file" > "$tmp_file" && mv "$tmp_file" "$state_file"
  log_info "Estado de '${feature_id}' marcado como completed."
else
  log_warn "No se encontró runtime/state/${feature_id}.yaml para actualizar."
fi

for worktrees_root in "${REPO_ROOT}"/repositories/*/.worktrees/"${feature_id}"; do
  [[ -d "$worktrees_root" ]] || continue
  log_warn "Quedan worktrees bajo '${worktrees_root#"${REPO_ROOT}"/}'; revisar manualmente antes de limpiar (scripts/cleanup-worktree.sh)."
done

log_event "hook" "$feature_id" "delivery" "ok" "post-delivery completado: $summary_file"
log_info "post-delivery OK para '${feature_id}'."
