#!/usr/bin/env bash
# pre-test.sh - Contraparte ejecutable de hooks/pre-test.md
#
# Uso: pre-test.sh <feature_id> [build_command...]
# Si se pasa un comando de build, lo ejecuta para verificar que el código
# está en estado ejecutable antes de correr/escribir pruebas.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/observability.sh
source "${SCRIPT_DIR}/../lib/observability.sh"

feature_id="${1:-}"
require_arg "feature_id" "$feature_id"
shift || true

if [[ $# -gt 0 ]]; then
  log_info "pre-test: ejecutando comando de verificación: $*"
  if ! "$@"; then
    log_error_event "$feature_id" "test" "el código no compila/arranca: $*"
    die "El comando de verificación falló: $*. El código no está en estado probable."
  fi
else
  log_warn "pre-test: no se indicó comando de build/arranque; se omite la verificación previa."
fi

log_event "hook" "$feature_id" "test" "ok" "pre-test completado"
log_info "pre-test OK para '${feature_id}'."
