#!/usr/bin/env bash
# engine.sh - Punto de entrada real del CLI `./orchestrator`.
#
# Este script es una utilidad de soporte, NO un runtime de agentes. Los
# comandos que expone sirven para validar el repositorio y guiar al cliente
# de IA activo (Codex, Claude Code, ...) a bootstrapear la orquestación real,
# que ocurre dentro de ese cliente siguiendo AGENTS.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=./lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'EOF'
Uso: ./orchestrator <comando> [argumentos]

Comandos:
  validate              Valida la estructura del repositorio (scripts/validate-structure.sh).
  bootstrap             Imprime las instrucciones de arranque para el cliente de IA activo.
  status <feature_id>   Muestra el estado persistido de una feature (runtime/state/<feature-id>.yaml).
  resolve <F{num}-P{fase}[-T{tarea}]>
                         Resuelve un selector de $task a los archivos de tarea concretos.
  security-scan [dir]   Escanea el repositorio (o <dir>) en busca de secretos.
  help                   Muestra esta ayuda.

Este CLI no ejecuta agentes de IA. Ver AGENTS.md y README.md para el flujo real.
EOF
}

cmd_validate() {
  exec "${ORCH_DIR}/scripts/validate-structure.sh"
}

cmd_bootstrap() {
  cat <<EOF
Para orquestar features en este repositorio con tu cliente de IA:

  1. Carga ${ORCH_DIR}/AGENTS.md como guía operativa.
  2. Usa los atajos soportados (ver orchestrator.yaml -> runtime.entrypoints):
       \$feat F{num}                      -> planifica features/F{num}-{slug}/ (sin código)
       \$task F{num}-P{fase}              -> implementa esa fase (código + revisión + pruebas)
       "implementa esta feature"          -> ejecuta el ciclo completo de punta a punta
  3. Cada fase carga el agente correspondiente en ${ORCH_DIR}/agents/
     y la skill correspondiente en ${ORCH_DIR}/skills/.
  4. El estado se persiste en ${ORCH_DIR}/runtime/state/<feature-id>.yaml

Ejecuta './orchestrator validate' antes de empezar para confirmar que la
estructura del repositorio es correcta.
EOF
}

cmd_status() {
  local feature_id="${1:-}"
  require_arg "feature_id" "$feature_id"
  local state_file="${ORCH_DIR}/runtime/state/${feature_id}.yaml"
  [[ -f "$state_file" ]] || die "No hay estado persistido para '${feature_id}' en ${state_file}"
  cat "$state_file"
}

cmd_resolve() {
  exec "${ORCH_DIR}/scripts/resolve-feature-tasks.sh" "$@"
}

cmd_security_scan() {
  exec "${ORCH_DIR}/scripts/security-scan.sh" "$@"
}

main() {
  local command="${1:-help}"
  [[ $# -gt 0 ]] && shift

  case "$command" in
    validate) cmd_validate "$@" ;;
    bootstrap) cmd_bootstrap "$@" ;;
    status) cmd_status "$@" ;;
    resolve) cmd_resolve "$@" ;;
    security-scan) cmd_security_scan "$@" ;;
    help|-h|--help) usage ;;
    *)
      log_error "Comando desconocido: ${command}"
      usage
      exit 1
      ;;
  esac
}

main "$@"
