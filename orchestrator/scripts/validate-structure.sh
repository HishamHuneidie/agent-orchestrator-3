#!/usr/bin/env bash
# validate-structure.sh - Fuente de verdad de la forma esperada del repositorio.
#
# Verifica que existen los archivos y directorios que ../ORCHESTRATOR-DOCUMENTATION.md
# describe como parte del control plane. Es deliberadamente estructural (existencia
# de rutas), no valida contenido — para eso está validate-contract.sh.
#
# Uso: scripts/validate-structure.sh
# Exit 0 si todo existe, exit 1 con el detalle de lo que falta si no.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${ORCH_DIR}/.." && pwd)"
cd "$ORCH_DIR"

missing=()

check_file() { [[ -f "$1" ]] || missing+=("archivo faltante: $1"); }
check_dir()  { [[ -d "$1" ]] || missing+=("directorio faltante: $1"); }
check_exec() { [[ -x "$1" ]] || missing+=("no ejecutable: $1"); }

# ============================================================
# Raíz del MONOREPO (padre de orchestrator/): AGENTS.md, CLAUDE.md,
# Makefile, compose.yaml, docs/, features/, orchestrator/, repositories/, scripts/
# ============================================================
check_file "${REPO_DIR}/AGENTS.md"
check_file "${REPO_DIR}/CLAUDE.md"
check_file "${REPO_DIR}/Makefile"
check_file "${REPO_DIR}/compose.yaml"
check_dir "${REPO_DIR}/docs"
check_dir "${REPO_DIR}/orchestrator"
check_dir "${REPO_DIR}/repositories"
check_dir "${REPO_DIR}/scripts"
# features/ es dinámico: se crea con la primera feature, no es obligatorio en
# un checkout nuevo. Si existe, valida su forma interna (ver más abajo).

# ============================================================
# Interno de orchestrator/
# ============================================================

# --- Raíz de orchestrator/ ---
check_file "README.md"
check_file "AGENTS.md"
check_file "orchestrator.yaml"
check_file "orchestrator"
check_exec "orchestrator"

# --- agents/ ---
check_dir "agents"
for a in orchestrator feature-analyst estimator implementation-planner \
         backend-engineer frontend-engineer fullstack-engineer code-reviewer \
         unit-test-engineer e2e-test-engineer qa-verifier delivery-summarizer; do
  check_file "agents/${a}.md"
done

# --- skills/ ---
check_dir "skills"
for s in agent-routing application-feature-orchestration code-review \
         delivery-summary estimation feature-from-docs feature-planning-shortcut \
         implementation-execution parallel-worktrees task-delivery-shortcut test-validation; do
  check_file "skills/${s}/SKILL.md"
done

# --- workflows/ ---
check_dir "workflows"
for w in application-feature feature-planning task-delivery \
         parallel-implementation review-and-test delivery-summary; do
  check_file "workflows/${w}.md"
done

# --- hooks/ (documental) ---
check_dir "hooks"
for h in pre-orchestration pre-agent-dispatch post-agent-dispatch \
         pre-review pre-test post-delivery; do
  check_file "hooks/${h}.md"
  check_file "runtime/hooks/${h}.sh"
  check_exec "runtime/hooks/${h}.sh"
done

# --- schemas/ ---
check_dir "schemas"
for s in feature-request brief execution-plan agent-task workflow-state \
         review-report test-report delivery-summary observability-event; do
  check_file "schemas/${s}.schema.yaml"
done

# --- templates/ ---
check_dir "templates"
for t in feature-request.yaml brief.yaml backend-brief.yaml frontend-brief.yaml \
         qa-brief.yaml review-brief.yaml feature-plan.md feature-task.md \
         execution-plan.yaml agent-task.yaml task.yaml workflow-state.yaml \
         prompt.md review-report.md test-report.md delivery-summary.md; do
  check_file "templates/${t}"
done

# --- runtime/ ---
check_file "runtime/engine.sh"
check_exec "runtime/engine.sh"
check_dir "runtime/lib"
for l in common observability schema security; do
  check_file "runtime/lib/${l}.sh"
done
check_dir "runtime/prompts"
check_dir "runtime/state"

# --- scripts/ ---
check_dir "scripts"
for s in validate-structure validate-contract orchestrate resolve-feature-tasks \
         create-worktree cleanup-worktree security-scan; do
  check_file "scripts/${s}.sh"
  check_exec "scripts/${s}.sh"
done

# --- docs/ ---
check_dir "docs"
for d in architecture architecture-refactor-report agent-lifecycle \
         ai-client-orchestration workflow-engine prompt-builder observability \
         operating-manual security worktree-strategy; do
  check_file "docs/${d}.md"
done
check_dir "docs/diagrams"
for d in agent-interactions execution-flow prompt-builder; do
  check_file "docs/diagrams/${d}.md"
done

# --- Directorios de datos ---
check_dir "observability"
check_file "observability/executions.jsonl"
check_dir "briefs"
check_dir "reports"
check_dir "contracts"

# ============================================================
# features/ (raíz del monorepo) — validación de forma, si existe.
# Convención: features/F{num}-{slug}/README.md (humano) +
#             features/F{num}-{slug}/P{fase}-{slug}/T{tarea}-*.md (generado)
# ============================================================
features_root="${REPO_DIR}/features"
if [[ -d "$features_root" ]]; then
  while IFS= read -r -d '' feature_dir; do
    feature_name="$(basename "$feature_dir")"
    if [[ ! "$feature_name" =~ ^F[0-9]+- ]]; then
      missing+=("features/${feature_name}: no sigue la convención F{num}-{slug}")
      continue
    fi
    [[ -f "${feature_dir}/README.md" ]] || missing+=("features/${feature_name}/README.md faltante")
    phase_found=0
    while IFS= read -r -d '' phase_dir; do
      phase_name="$(basename "$phase_dir")"
      if [[ ! "$phase_name" =~ ^P[0-9]+- ]]; then
        missing+=("features/${feature_name}/${phase_name}: no sigue la convención P{fase}-{slug}")
        continue
      fi
      phase_found=1
      if ! find "$phase_dir" -maxdepth 1 -type f -name 'T*.md' -print -quit | grep -q .; then
        missing+=("features/${feature_name}/${phase_name}/: no contiene ninguna tarea T*.md")
      fi
    done < <(find "$feature_dir" -mindepth 1 -maxdepth 1 -type d -print0)
    # phase_found puede ser 0 legítimamente si la feature aún no pasó por $feat; no es un error.
  done < <(find "$features_root" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Estructura invalida. Faltan ${#missing[@]} elemento(s):" >&2
  for m in "${missing[@]}"; do
    echo "  - $m" >&2
  done
  exit 1
fi

echo "OK: la estructura del monorepo y del orquestador coinciden con la convención esperada"
