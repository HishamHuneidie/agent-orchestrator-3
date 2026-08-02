.PHONY: help setup validate up down logs ps feat task

help:
	@echo "Targets disponibles:"
	@echo "  setup     - Prepara el entorno local (scripts/setup.sh)"
	@echo "  validate  - Valida la estructura del monorepo y del orquestador"
	@echo "  up        - Levanta los repositorios de aplicación (docker compose)"
	@echo "  down      - Detiene los repositorios de aplicación"
	@echo "  logs      - Sigue los logs de docker compose"
	@echo "  ps        - Lista los servicios en ejecución"
	@echo ""
	@echo "Atajos del orquestador (ejecutar dentro de tu cliente de IA, no aquí):"
	@echo "  \$$feat F{num}              - planifica una feature"
	@echo "  \$$task F{num}-P{fase}      - implementa una fase"

setup:
	./scripts/setup.sh

validate:
	./orchestrator/scripts/validate-structure.sh
	./orchestrator/scripts/security-scan.sh .

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps
