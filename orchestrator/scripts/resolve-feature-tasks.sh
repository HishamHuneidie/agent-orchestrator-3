#!/usr/bin/env bash
# resolve-feature-tasks.sh - Resuelve el selector de `$task F{num}-P{fase}[-T{tarea}]`
# a los archivos de tarea concretos dentro de features/F{num}-{slug}/P{fase}-{slug}/
# (features/ vive en la raíz del monorepo, hermano de orchestrator/).
#
# Uso: scripts/resolve-feature-tasks.sh <selector>
#
# Formatos válidos de <selector>:
#   F01-P01       -> todas las tareas (T*.md) de la carpeta de fase P01-{slug}/
#   F01-P01-T01   -> únicamente esa tarea (T01-{slug}.md)
#
# Imprime, una por línea, la ruta de cada archivo de tarea resuelto.
# Exit 1 si el selector no resuelve a ninguna tarea.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../runtime/lib/common.sh
source "${ORCH_DIR}/runtime/lib/common.sh"

selector="${1:-}"
require_arg "selector" "$selector"

if [[ ! "$selector" =~ ^(F[0-9]+)-(P[0-9]+)(-(T[0-9]+))?$ ]]; then
  die "Selector no reconocido: '${selector}'. Formato esperado: F{num}-P{fase}[-T{tarea}] (p. ej. F01-P01 o F01-P01-T01)."
fi
feature_prefix="${BASH_REMATCH[1]}"
phase_prefix="${BASH_REMATCH[2]}"
task_prefix="${BASH_REMATCH[4]:-}"

feature_dir="$(resolve_feature_dir "$feature_prefix")"
phase_dir="$(resolve_phase_dir "$feature_dir" "$phase_prefix")"

if [[ -n "$task_prefix" ]]; then
  pattern="${task_prefix}-*.md"
else
  pattern="T*.md"
fi

matches=()
while IFS= read -r -d '' f; do matches+=("$f"); done \
  < <(find "$phase_dir" -maxdepth 1 -type f -name "$pattern" -print0 | sort -z)

if [[ ${#matches[@]} -eq 0 ]]; then
  die "El selector '${selector}' no resolvió a ninguna tarea en ${phase_dir}."
fi

printf '%s\n' "${matches[@]}"
