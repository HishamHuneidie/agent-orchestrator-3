#!/usr/bin/env bash
# pre-review.sh - Contraparte ejecutable de hooks/pre-review.md
#
# Uso: pre-review.sh <feature_id> <target_dir_or_diff_ref>
# Verifica que hay cambios que revisar antes de despachar a code-reviewer.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/observability.sh
source "${SCRIPT_DIR}/../lib/observability.sh"

feature_id="${1:-}"; target="${2:-.}"
require_arg "feature_id" "$feature_id"

if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git -C "$target" diff --quiet && git -C "$target" diff --cached --quiet; then
    log_error_event "$feature_id" "review" "no hay cambios que revisar en $target"
    die "No se detectaron cambios de código en '$target' para revisar."
  fi
else
  log_warn "El directorio '$target' no es un repositorio git; se omite la verificación de diff."
fi

log_event "hook" "$feature_id" "review" "ok" "pre-review completado sobre $target"
log_info "pre-review OK para '${feature_id}'."
