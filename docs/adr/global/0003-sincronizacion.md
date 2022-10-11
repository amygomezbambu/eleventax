**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Eleventa debe sincronizar sus datos entre los dispositivos que pertenecen a una misma sucursal, esto con el fin de
que los usuarios puedan ver y modificar todos sus datos en cualquier dispositivo, ya sea que se encuentren en la misma
localización fisica o conectados a internet en distintos lugares

# Opciones evaluadas

- Usar un servicio de terceros
- Implementar la logica internamente

# Decisión

Decidimos implementar la logica internamente debido a varios factores:

1. Soportar la sincronización bajo un base de datos relacional (SQLite) y tener control absoluto de los datos y su almacenamiento.
2. No estar forzados a usar un solo proveedor, si usamos algun servicio y por algun motivo decidimos cambiar tendriamos
que reimplmentar el adaptador de sincronización completo, sin embargo al usar una solución propia mas generica podemos
cambiar de proveedor sin tener que modificar gran parte del codigo ya que esta hecho en javascript y puede correr en 
cualquier ambiente que soporte este lenguaje.
3. Tener libertad de agregar features que necesitamos, la mayoria de los servicios de terceros requieren que siempre
estes conectado a internet o no tienen soporte para todas las plataformas, en nuestro caso casi ningun servicio
tiene soporte para Flutter Desktop.


# Consecuencias

- No se pueden crear o modificar datos directamente en la base de datos, solo se permite consultar, todos los insert,
updates y deletes tienes que pasar a travez del modulo de sincronización.


# Referencias

Si deseas conocer exactamente como funciona la sincronización puedes consultar la referencia en **[basecamp](https://3.basecamp.com/3077179/buckets/25852/messages/4211237591)**


