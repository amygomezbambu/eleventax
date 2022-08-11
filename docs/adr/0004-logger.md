**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto
Se evaluó el uso de un paquete de logueo para poder registrar los errores, warnings, información, etc, ocurridos en el proyecto y poder tener una base de los hechos ocurridos hasta la aparición del problema.


# Opciones evaluadas
-logging (https://pub.dev/packages/logging)
-logger  (https://pub.dev/packages/logger)
-loggy   (https://pub.dev/packages/loggy)



# Decisión
Se decidió la opción de logging debido a que no lo desarrolla una única persona, es desarrollado por el equipo de dart así que nos evitará problemas de que deje de ser actualizado, además cuenta con integración con Sentry.io lo que nos permitirá contar con un registro y envío de errores más completo.


# Consecuencias
Se tendrán que modificar los métodos implementados de la clase que loguea en eleventax por los métodos y funciones que tiene la librería.
