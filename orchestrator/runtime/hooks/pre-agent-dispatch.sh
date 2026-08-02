#!/usr/bin/env bash
# pre-agent-dispatch.sh - Contraparte ejecutable de hooks/pre-agent-dispatch.md
#
# Uso: pre-agent-dispatch.sh <feature_id> <phase> <agent_name> [required_input_file ...]
# Verifica que los inputs obligatorios existen y que ninguna ruta objetivo
# está en una raíz prohibida, antes de despachar trabajo a un agente.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/observability.sh
source "${SCRIPT_DIR}/../lib/observability.sh"
# shellcheck source=../lib/security.sh
source "${SCRIPT_DIR}/../lib/security.sh"

feature_id="${1:-}"; phase="${2:-}"; agent_name="${3:-}"
require_arg "feature_id" "$feature_id"
require_arg "phase" "$phase"
require_arg "agent_name" "$agent_name"
shift 3 || true
required_inputs=("$@")

for input in "${required_inputs[@]:-}"; do
  [[ -z "$input" ]] && continue
  rel_input="${input#"${ORCH_ROOT}"/}"
  if path_is_forbidden "$rel_input"; then
    log_error_event "$feature_id" "$phase" "input en ruta prohibida: $rel_input"
    die "El input '$rel_input' está en una raíz totalmente prohibida (.git)."
  fi
  if [[ ! -e "$input" ]]; then
    log_error_event "$feature_id" "$phase" "input obligatorio faltante: $rel_input"
    die "Input obligatorio faltante para despachar '$agent_name': $input"
  fi
done

log_event "hook" "$feature_id" "$phase" "ok" "pre-agent-dispatch: $agent_name autorizado"
log_info "pre-agent-dispatch OK: '$agent_name' puede ejecutar la fase '$phase' de '$feature_id'."
