#!/usr/bin/env python3
"""Validador estructural mínimo de un YAML de datos contra un YAML de schema.

No es un motor JSON Schema completo. Los schemas de este repositorio (ver
schemas/*.schema.yaml) declaran, como maximo:

    required:
      - campo_a
      - campo_b.subcampo
    properties:
      campo_a: {type: string}
      campo_b: {type: object}

Uso: _schema_validate.py <data.yaml> <schema.schema.yaml>
Exit 0 si valida, exit 1 y mensaje en stderr si no.
"""
import sys
import yaml

TYPE_MAP = {
    "string": str,
    "number": (int, float),
    "integer": int,
    "boolean": bool,
    "object": dict,
    "array": list,
}


def get_path(data, dotted_path):
    node = data
    for part in dotted_path.split("."):
        if not isinstance(node, dict) or part not in node:
            return None, False
        node = node[part]
    return node, True


def main():
    if len(sys.argv) != 3:
        print("uso: _schema_validate.py <data.yaml> <schema.schema.yaml>", file=sys.stderr)
        return 2

    data_path, schema_path = sys.argv[1], sys.argv[2]

    with open(data_path) as f:
        data = yaml.safe_load(f) or {}
    with open(schema_path) as f:
        schema = yaml.safe_load(f) or {}

    errors = []

    for required_field in schema.get("required", []):
        value, present = get_path(data, required_field)
        if not present:
            errors.append(f"falta el campo obligatorio: {required_field}")

    for field, spec in (schema.get("properties") or {}).items():
        value, present = get_path(data, field)
        if not present:
            continue
        expected_type = spec.get("type") if isinstance(spec, dict) else None
        py_type = TYPE_MAP.get(expected_type)
        if py_type and not isinstance(value, py_type):
            errors.append(
                f"campo '{field}' tiene tipo {type(value).__name__}, se esperaba {expected_type}"
            )

    if errors:
        print(f"Validacion fallida para {data_path} contra {schema_path}:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"OK: {data_path} valida contra {schema_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
