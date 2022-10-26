**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Necesitamos generar identificadores unicos para las entidades, esto con el fin de no depender
de identificadores auto-incrementales ya que eleventa es un sistema distribuido y es bien
conocido que en este tipo de sistemas los indetificadores auto-incrementales tienes varios problemas.

# Opciones evaluadas

- UUID v4
- UUID v7
- NanoID
- XID

# Decisión

Decidimos usar NanoID debido a que nuestra primera opción la cual era XID presenta un fallo aleatorio durante las pruebas.

La segunda mejor opción es NanoID debido a su tamaño mas compacto y mayor velocidad de generación que UUID.

# Consecuencias

Debemos refactorizar las clases necesarias para usar la nueva libreria.
