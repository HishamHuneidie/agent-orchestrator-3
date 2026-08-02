#!/usr/bin/env bash
# common.sh - Utilidades compartidas por scripts del runtime y hooks ejecutables.
# Uso: source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

set -euo pipefail

# Raíz de /orchestrator, independientemente de desde dónde se invoque el script.
orch_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

ORCH_ROOT="$(orch_root)"

# Raíz del monorepo (padre de orchestrator/). features/, repositories/, docs/ y
# scripts/ de uso general viven aquí, como hermanos de orchestrator/.
REPO_ROOT="$(cd "${ORCH_ROOT}/.." && pwd)"

log_info()  { printf '[INFO]  %s\n' "$*" >&2; }
log_warn()  { printf '[WARN]  %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

die() {
  log_error "$*"
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Comando requerido no encontrado: $1"
}

require_arg() {
  local name="$1" value="${2:-}"
  [[ -n "$value" ]] || die "Argumento requerido faltante: $name"
}

# Deriva un feature-id seguro para nombres de archivo/directorio a partir de un
# feature_name arbitrario. Preserva mayúsculas/minúsculas (p. ej. "F01-collaborative-lab"
# se mantiene igual, para coincidir con el nombre real del directorio en features/),
# solo sanea caracteres no seguros para nombres de archivo.
to_feature_id() {
  local raw="$1"
  echo "$raw" | tr -c 'A-Za-z0-9-' '-' | sed 's/-\+/-/g; s/^-//; s/-$//'
}

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

ensure_dir() {
  mkdir -p "$1"
}

# resolve_feature_dir <F{num}> -> imprime la ruta absoluta del directorio
# features/F{num}-{slug}/ único que coincide con ese prefijo (features/ vive en
# la raíz del monorepo, hermano de orchestrator/). Falla si no existe ninguno
# o si existe más de uno (prefijo ambiguo).
resolve_feature_dir() {
  local prefix="$1"
  require_arg "feature_prefix" "$prefix"
  local matches=("${REPO_ROOT}/features/${prefix}-"*/)
  if [[ ! -d "${matches[0]}" ]]; then
    die "No existe ninguna feature bajo features/${prefix}-*/. Créala primero (features/${prefix}-{slug}/README.md)."
  fi
  if [[ ${#matches[@]} -gt 1 ]]; then
    die "Más de una feature coincide con el prefijo '${prefix}-*': ${matches[*]}"
  fi
  printf '%s\n' "${matches[0]%/}"
}

# resolve_phase_dir <feature_dir> <P{fase}> -> imprime la ruta absoluta de la
# carpeta de fase P{fase}-{slug}/ única dentro de <feature_dir>. Falla si no
# existe ninguna o si existe más de una (prefijo ambiguo).
resolve_phase_dir() {
  local feature_dir="$1" phase_prefix="$2"
  require_arg "feature_dir" "$feature_dir"
  require_arg "phase_prefix" "$phase_prefix"
  local matches=("${feature_dir}/${phase_prefix}-"*/)
  if [[ ! -d "${matches[0]}" ]]; then
    die "No existe ninguna fase bajo $(basename "$feature_dir")/${phase_prefix}-*/."
  fi
  if [[ ${#matches[@]} -gt 1 ]]; then
    die "Más de una fase coincide con el prefijo '${phase_prefix}-*' en $(basename "$feature_dir")/: ${matches[*]}"
  fi
  printf '%s\n' "${matches[0]%/}"
}
