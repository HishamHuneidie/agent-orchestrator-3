#!/usr/bin/env bash
# setup.sh - Prepara el entorno local del monorepo.
#
# Placeholder: ajusta este script a las necesidades reales de los repos bajo
# repositories/ (instalar dependencias, copiar .env de ejemplo, etc.).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Preparando carpetas..."
rm -rf "${ROOT_DIR}/.git"
rm "${ROOT_DIR}/README.md"
mkdir docs features repositories
git init
git add .
git commit -m 'init: Start app'
git branch -M master

echo "Validando estructura del orquestador..."
"${ROOT_DIR}/orchestrator/scripts/validate-structure.sh"

echo "Repositorios de aplicación detectados en repositories/:"
find "${ROOT_DIR}/repositories" -maxdepth 1 -mindepth 1 -type d -printf '  - %f\n' 2>/dev/null || true

echo "Setup base completo. Añade aquí los pasos específicos de cada repositorio."
