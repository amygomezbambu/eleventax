**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Es necesario tener documentación de las decisiones de arquitectura de la aplicación, esto
para futuras referencias y entender el razonamiento que se siguió al tomar la decisión.

# Decisión

Se utilizaran ARDs para documentar las decisiones, se manejaran 2 estados para las revisiones, el primero es "En espera de revisión" cuando el ARD es aun una propuesta, y el segundo "Aceptado".

Cuando sea conveniente al agregar una dependencia en pubspec.yaml, se incluirá en comentarios el ID de la decisión que lo respalda, ejem: `# [ADR-0003]`.

# Consecuencias

Ya que estamos en estapas tempranas del proyecto no es necesaria ninguna accion adicional.
