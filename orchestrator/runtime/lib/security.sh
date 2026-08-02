#!/usr/bin/env bash
# security.sh - Escaneo de secretos y validación de rutas/permisos.
# Los patrones aquí deben mantenerse sincronizados manualmente con
# orchestrator.yaml -> security. Uso: source "$(dirname "${BASH_SOURCE[0]}")/security.sh"

set -euo pipefail

SCRIPT_DIR_SEC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR_SEC}/common.sh"

# Patrones de ruta denegados (nombre de archivo, no contenido).
SECURITY_DENIED_PATH_PATTERNS=(
  '\.env($|\.)'
  'secret'
  'token'
  'credential'
  '\.pem$'
  '\.crt$'
  '\.key$'
  '\.p12$'
  '^id_rsa'
  '^id_ed25519'
)

# Patrones de contenido denegados (secretos incrustados en archivos).
SECURITY_DENIED_CONTENT_PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  '-----BEGIN[ A-Z]*PRIVATE KEY-----'
  '(?i)api_key[[:space:]]*=[[:space:]]*.{12,}'
  '(?i)secret[[:space:]]*=[[:space:]]*.{12,}'
  '(?i)token[[:space:]]*=[[:space:]]*.{12,}'
  '(?i)password[[:space:]]*=[[:space:]]*.{8,}'
)

# path_is_forbidden <relative_path> -> 0 si contiene un componente .git, .codex
# o .claude a CUALQUIER profundidad (p. ej. repositories/<repo-name>/.git/...
# si ese repo es su propio repositorio git, no solo en la raíz del monorepo).
# .codex/ y .claude/ son directorios de tooling de los clientes de IA
# soportados (Codex y Claude Code respectivamente): metadatos/config de la
# herramienta, no código ni datos de la aplicación.
path_is_forbidden() {
  local path="$1"
  case "/${path}/" in
    */.git/*|*/.codex/*|*/.claude/*) return 0 ;;
  esac
  return 1
}

# path_matches_denied_pattern <relative_path> -> 0 si el nombre coincide con un patrón denegado
path_matches_denied_pattern() {
  local path="$1" pattern
  for pattern in "${SECURITY_DENIED_PATH_PATTERNS[@]}"; do
    if echo "$path" | grep -Eiq "$pattern"; then
      return 0
    fi
  done
  return 1
}

# scan_file_for_secrets <file> -> imprime líneas sospechosas; devuelve 0 si está limpio, 1 si encontró algo
scan_file_for_secrets() {
  local file="$1" pattern found_secret=1
  [[ -f "$file" ]] || return 0
  for pattern in "${SECURITY_DENIED_CONTENT_PATTERNS[@]}"; do
    if grep -nP "$pattern" "$file" 2>/dev/null; then
      found_secret=0
    fi
  done
  # found_secret: 0 = se encontró un patrón (hay que devolver 1 = "sucio"); 1 = ninguno (devolver 0 = "limpio")
  [[ $found_secret -eq 0 ]] && return 1 || return 0
}

# scan_tree_for_secrets <dir> -> escanea recursivamente, respetando .git/.codex
# Devuelve 0 si todo el árbol está limpio, 1 si se encontró al menos un secreto.
scan_tree_for_secrets() {
  local dir="$1" any_found=0
  while IFS= read -r -d '' file; do
    local rel="${file#"$dir"/}"
    path_is_forbidden "$rel" && continue
    if ! scan_file_for_secrets "$file" >/dev/null; then
      log_warn "Posible secreto detectado en: $rel"
      any_found=1
    fi
  done < <(find "$dir" \( -type d \( -name .git -o -name .codex -o -name .claude \) \) -prune -o -type f -print0)
  return $any_found
}
