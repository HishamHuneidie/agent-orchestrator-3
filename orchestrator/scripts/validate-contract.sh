#!/usr/bin/env bash
# validate-contract.sh - Valida un contrato YAML concreto contra su schema.
#
# Uso: scripts/validate-contract.sh <data.yaml> [schema.schema.yaml]
# Si no se indica el schema, se infiere por el nombre del schema_id declarado
# dentro del propio archivo de schema correspondiente en schemas/, buscando
# por convención de nombre (p. ej. briefs/x/brief.yaml -> schemas/brief.schema.yaml).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../runtime/lib/common.sh
source "${ORCH_DIR}/runtime/lib/common.sh"
# shellcheck source=../runtime/lib/schema.sh
source "${ORCH_DIR}/runtime/lib/schema.sh"

data_file="${1:-}"
schema_file="${2:-}"
require_arg "data_file" "$data_file"

if [[ -z "$schema_file" ]]; then
  base="$(basename "$data_file")"
  case "$base" in
    brief.yaml|estimate.yaml) schema_file="${ORCH_DIR}/schemas/brief.schema.yaml" ;;
    feature-request.yaml) schema_file="${ORCH_DIR}/schemas/feature-request.schema.yaml" ;;
    execution-plan.yaml) schema_file="${ORCH_DIR}/schemas/execution-plan.schema.yaml" ;;
    agent-task.yaml) schema_file="${ORCH_DIR}/schemas/agent-task.schema.yaml" ;;
    *)
      die "No se pudo inferir el schema para '${data_file}'. Indícalo explícitamente como segundo argumento."
      ;;
  esac
fi

validate_yaml_against_schema "$data_file" "$schema_file"
