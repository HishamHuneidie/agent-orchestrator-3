#!/usr/bin/env bash
# security-scan.sh - Escaneo de secretos/material sensible.
#
# Uso: scripts/security-scan.sh [directorio]
# Por defecto escanea la raíz del repositorio (excluyendo .git/).
# Exit 1 si encuentra coincidencias con orchestrator.yaml -> security.denied_content_patterns
# o rutas que coinciden con security.denied_path_patterns.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${ORCH_DIR}/.." && pwd)"

# shellcheck source=../runtime/lib/common.sh
source "${ORCH_DIR}/runtime/lib/common.sh"
# shellcheck source=../runtime/lib/security.sh
source "${ORCH_DIR}/runtime/lib/security.sh"

target_dir="${1:-$REPO_ROOT}"
[[ -d "$target_dir" ]] || die "Directorio no encontrado: $target_dir"

log_info "Escaneando rutas denegadas y contenido sensible en: $target_dir"

path_violations=0
while IFS= read -r -d '' file; do
  rel="${file#"$target_dir"/}"
  path_is_forbidden "$rel" && continue
  if path_matches_denied_pattern "$(basename "$rel")"; then
    log_warn "Ruta con patrón denegado: $rel"
    path_violations=$((path_violations + 1))
  fi
done < <(find "$target_dir" -type d -name .git -prune -o -type f -print0)

content_violations=0
if ! scan_tree_for_secrets "$target_dir"; then
  content_violations=1
fi

if [[ $path_violations -gt 0 || $content_violations -gt 0 ]]; then
  log_error "Escaneo de seguridad FALLIDO: ${path_violations} ruta(s) denegada(s), contenido sensible: $([[ $content_violations -gt 0 ]] && echo sí || echo no)."
  exit 1
fi

echo "OK: sin rutas denegadas ni contenido sensible detectado en $target_dir"
