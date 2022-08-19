**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Toda aplicación requiere mantener e informar el historial de cambios que cada versión contiene para que el usuario final esté informado de mejoras, correcciones, etc. el estandarizar desde una etapa temprana estos cambios facilitará los procesos de despliegue continuo entre otros.

# Opciones evaluadas

- Extraer los cambios del historial de commits.
- Manejar los cambios especificos para el usuario por medio del estándard keep-a-changelog.

# Decisión

Se decidió llevar el historial de cambios siguiendo la propuesta de (Keep-A-Changelog)[https://keepachangelog.com/es-ES/1.0.0/] para mantener separados el historial de cambios de los desarrolladores de los visibles a los usuarios finales. La discusión de la propuesta original se hizo en: https://3.basecamp.com/3077179/buckets/24370156/messages/5123629198

# Consecuencias

Asegurar por medio de procesos que cada pull request considere/se asegure de actualizar el archivo CHANGELOG.md para mantenerlo vigente.
