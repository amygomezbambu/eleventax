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

Decidimos utilizar XID ya que su tamaño es mas pequeño que todas las otras opciones, es mas rapido y cumple con todos los criterios de selección.


# Consecuencias

Debemos refactorizar las clases necesarias para usar la nueva libreria.
