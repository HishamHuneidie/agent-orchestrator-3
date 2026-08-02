# Hook: pre-test

## Propósito

Se ejecuta antes de ejecutar pruebas (unitarias, e2e o verificación QA). Verifica que el código a probar está en un estado ejecutable (compila/arranca) antes de invertir esfuerzo en escribir o correr pruebas sobre código roto.

## Cuándo se ejecuta

Justo antes de despachar a `unit-test-engineer`, `e2e-test-engineer` o `qa-verifier` para la fase `test`.

## Inputs

- Referencia a la tarea/fase.
- Comandos de build/arranque del proyecto (si existen y son conocidos).

## Outputs

- Confirmación de que el código está en estado probable, o un bloqueo si no compila/arranca.

## Errores posibles

- El código no compila o el proyecto no arranca.
- Faltan dependencias/variables de entorno necesarias para ejecutar la suite (deben documentarse, no simularse).
- La revisión de código (`review`) aún no se completó y la política del workflow exige revisión antes de test.

## Componente ejecutable correspondiente

`runtime/hooks/pre-test.sh`
