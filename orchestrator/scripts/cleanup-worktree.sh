#!/usr/bin/env bash
# cleanup-worktree.sh - Elimina un worktree `<feature-id>/<task-id>` de
# repositories/<repo-name>/ tras su uso.
#
# Uso: scripts/cleanup-worktree.sh <repo-name> <feature-id> <task-id> [--force]
#
# Por seguridad, se niega a eliminar un worktree con cambios sin commitear o
# sin fusionar a menos que se pase --force explícitamente.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MONOREPO_ROOT="$(cd "${ORCH_DIR}/.." && pwd)"

# shellcheck source=../runtime/lib/common.sh
source "${ORCH_DIR}/runtime/lib/common.sh"
# shellcheck source=../runtime/lib/observability.sh
source "${ORCH_DIR}/runtime/lib/observability.sh"

repo_name="${1:-}"; feature_id="${2:-}"; task_id="${3:-}"; force_flag="${4:-}"
require_arg "repo-name" "$repo_name"
require_arg "feature-id" "$feature_id"
require_arg "task-id" "$task_id"
require_cmd git

repo_dir="${MONOREPO_ROOT}/repositories/${repo_name}"
[[ -d "$repo_dir" ]] || die "No existe repositories/${repo_name}/."

cd "$repo_dir"
worktree_path=".worktrees/${feature_id}/${task_id}"
branch_name="worktree/${feature_id}/${task_id}"

[[ -d "$worktree_path" ]] || { log_warn "No existe el worktree: repositories/${repo_name}/${worktree_path}"; exit 0; }

if [[ "$force_flag" != "--force" ]]; then
  if ! git -C "$worktree_path" diff --quiet || ! git -C "$worktree_path" diff --cached --quiet; then
    log_error_event "$feature_id" "implementation" "worktree con cambios sin commitear: repositories/${repo_name}/${worktree_path}"
    die "El worktree 'repositories/${repo_name}/${worktree_path}' tiene cambios sin commitear. Intégralos o usa --force para descartarlos."
  fi
fi

git worktree remove "$worktree_path" ${force_flag:+--force}
git branch -D "$branch_name" 2>/dev/null || log_warn "No se pudo eliminar la rama ${branch_name} (puede que ya no exista o no esté fusionada)."

log_event "worktree" "$feature_id" "implementation" "ok" "worktree eliminado: repositories/${repo_name}/${worktree_path}"
log_info "Worktree eliminado: repositories/${repo_name}/${worktree_path}"
