#!/usr/bin/env bash
# observability.sh - Registro de eventos/métricas en observability/executions.jsonl
# Uso: source "$(dirname "${BASH_SOURCE[0]}")/observability.sh"

set -euo pipefail

SCRIPT_DIR_OBS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR_OBS}/common.sh"

OBSERVABILITY_LOG="${ORCH_ROOT}/observability/executions.jsonl"

# Escapa comillas dobles y backslashes para incrustar un string como valor JSON.
_json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

# log_event <event_type> <feature_id> <phase> <status> [detail]
log_event() {
  local event_type="$1" feature_id="$2" phase="$3" status="$4" detail="${5:-}"
  ensure_dir "$(dirname "$OBSERVABILITY_LOG")"
  local ts
  ts="$(timestamp_utc)"
  printf '{"timestamp":"%s","event_type":"%s","feature_id":"%s","phase":"%s","status":"%s","detail":"%s"}\n' \
    "$(_json_escape "$ts")" \
    "$(_json_escape "$event_type")" \
    "$(_json_escape "$feature_id")" \
    "$(_json_escape "$phase")" \
    "$(_json_escape "$status")" \
    "$(_json_escape "$detail")" >> "$OBSERVABILITY_LOG"
}

log_error_event() {
  local feature_id="$1" phase="$2" detail="$3"
  log_event "error" "$feature_id" "$phase" "failed" "$detail"
}
