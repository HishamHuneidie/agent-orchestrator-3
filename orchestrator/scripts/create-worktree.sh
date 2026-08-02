#!/usr/bin/env bash
# create-worktree.sh - Crea un worktree `<feature-id>/<task-id>` dentro del
# repositorio de aplicación repositories/<repo-name>/ (NO en la raíz del
# monorepo ni en orchestrator/).
#
# Uso: scripts/create-worktree.sh <repo-name> <feature-id> <task-id> [base_branch]
# Convención de rama: worktree/<feature-id>/<task-id>
# Convención de ruta: repositories/<repo-name>/.worktrees/<feature-id>/<task-id>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MONOREPO_ROOT="$(cd "${ORCH_DIR}/.." && pwd)"

# shellcheck source=../runtime/lib/common.sh
source "${ORCH_DIR}/runtime/lib/common.sh"
# shellcheck source=../runtime/lib/observability.sh
source "${ORCH_DIR}/runtime/lib/observability.sh"

repo_name="${1:-}"; feature_id="${2:-}"; task_id="${3:-}"; base_branch="${4:-}"
require_arg "repo-name" "$repo_name"
require_arg "feature-id" "$feature_id"
require_arg "task-id" "$task_id"
require_cmd git

repo_dir="${MONOREPO_ROOT}/repositories/${repo_name}"
[[ -d "$repo_dir" ]] || die "No existe repositories/${repo_name}/. Repositorios disponibles: $(ls "${MONOREPO_ROOT}/repositories" 2>/dev/null | tr '\n' ' ')"

cd "$repo_dir"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "repositories/${repo_name}/ no es un repositorio git (¿falta 'git init' o el clone real?)."

if [[ -z "$base_branch" ]]; then
  base_branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)"
fi

worktree_path=".worktrees/${feature_id}/${task_id}"
branch_name="worktree/${feature_id}/${task_id}"

if [[ -d "$worktree_path" ]]; then
  log_warn "El worktree ya existe: repositories/${repo_name}/${worktree_path}"
  log_event "worktree" "$feature_id" "implementation" "ok" "worktree ya existente: repositories/${repo_name}/${worktree_path}"
  echo "${repo_dir}/${worktree_path}"
  exit 0
fi

ensure_dir ".worktrees/${feature_id}"

if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
  git worktree add "$worktree_path" "$branch_name"
else
  git worktree add -b "$branch_name" "$worktree_path" "$base_branch"
fi

log_event "worktree" "$feature_id" "implementation" "ok" "worktree creado: repositories/${repo_name}/${worktree_path} (rama ${branch_name})"
log_info "Worktree creado en repositories/${repo_name}/${worktree_path} (rama ${branch_name}, base ${base_branch})"
echo "${repo_dir}/${worktree_path}"
