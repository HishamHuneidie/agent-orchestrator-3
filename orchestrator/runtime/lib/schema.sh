#!/usr/bin/env bash
# schema.sh - Validación estructural de contratos YAML contra schemas/*.schema.yaml
# Uso: source "$(dirname "${BASH_SOURCE[0]}")/schema.sh"
#
# Los schemas de este repositorio son deliberadamente simples: un documento YAML
# que declara `required` (lista de claves top-level obligatorias) y opcionalmente
# `properties` (tipos esperados por clave). No es JSON Schema completo; es lo
# mínimo necesario para detectar contratos incompletos o mal formados sin
# depender de librerías externas más allá de PyYAML (ya presente en el sistema).

set -euo pipefail

SCRIPT_DIR_SCHEMA="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR_SCHEMA}/common.sh"

_SCHEMA_VALIDATOR_PY="${SCRIPT_DIR_SCHEMA}/../../scripts/_schema_validate.py"

# validate_yaml_against_schema <data_file.yaml> <schema_file.schema.yaml>
# Devuelve 0 si válido, 1 si inválido (con detalle en stderr).
validate_yaml_against_schema() {
  local data_file="$1" schema_file="$2"
  require_cmd python3
  [[ -f "$data_file" ]] || { log_error "Archivo de datos no encontrado: $data_file"; return 1; }
  [[ -f "$schema_file" ]] || { log_error "Schema no encontrado: $schema_file"; return 1; }
  python3 "$_SCHEMA_VALIDATOR_PY" "$data_file" "$schema_file"
}

# is_valid_yaml <file> -> 0 si el archivo parsea como YAML válido
is_valid_yaml() {
  local file="$1"
  require_cmd python3
  python3 -c "import sys, yaml; yaml.safe_load(open(sys.argv[1]))" "$file" 2>/dev/null
}
