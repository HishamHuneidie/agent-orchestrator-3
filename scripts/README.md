# scripts/

Scripts sh/bash de uso general del monorepo: setup del entorno, atajos de build/arranque para los repos bajo `repositories/`, mantenimiento puntual, etc.

Esto es distinto de [`orchestrator/scripts/`](../orchestrator/scripts/), que contiene los scripts **propios del orquestador** (validación de estructura y contratos, resolución de selectores `$task`, gestión de worktrees, escaneo de seguridad) y no deben moverse ni duplicarse aquí.

Ejemplo de uso típico desde el `Makefile` de la raíz:

```makefile
setup:
	./scripts/setup.sh
```
