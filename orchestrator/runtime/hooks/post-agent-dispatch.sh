#!/usr/bin/env bash
# post-agent-dispatch.sh - Contraparte ejecutable de hooks/post-agent-dispatch.md
#
# Uso: post-agent-dispatch.sh <feature_id> <phase> <output_file> [schema_file]
# Escanea el output producido en busca de secretos y, si se indica un schema,
# lo valida contra él. Registra observabilidad del resultado.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/observability.sh
source "${SCRIPT_DIR}/../lib/observability.sh"
# shellcheck source=../lib/security.sh
source "${SCRIPT_DIR}/../lib/security.sh"
# shellcheck source=../lib/schema.sh
source "${SCRIPT_DIR}/../lib/schema.sh"

feature_id="${1:-}"; phase="${2:-}"; output_file="${3:-}"; schema_file="${4:-}"
require_arg "feature_id" "$feature_id"
require_arg "phase" "$phase"
require_arg "output_file" "$output_file"

if [[ ! -e "$output_file" ]]; then
  log_error_event "$feature_id" "$phase" "artefacto de salida no encontrado: $output_file"
  die "El agente reportó éxito pero no se encontró el artefacto esperado: $output_file"
fi

if [[ -f "$output_file" ]] && ! scan_file_for_secrets "$output_file"; then
  log_error_event "$feature_id" "$phase" "secreto detectado en: $output_file"
  die "Se detectó contenido sensible en '$output_file'. Deteniendo (error no reintentable)."
fi

if [[ -n "$schema_file" ]]; then
  if ! validate_yaml_against_schema "$output_file" "$schema_file"; then
    log_error_event "$feature_id" "$phase" "schema invalido: $output_file vs $schema_file"
    die "El artefacto '$output_file' no valida contra '$schema_file'."
  fi
fi

log_event "hook" "$feature_id" "$phase" "ok" "post-agent-dispatch: $output_file validado"
log_info "post-agent-dispatch OK: '$output_file' validado para la fase '$phase' de '$feature_id'."
