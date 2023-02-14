**Status:** Aceptado
<br>
**Modulo Afectado:** Productos

# Contexto

Al momento de realizar las ventas y persistir los articulos requerimos guardar los datos del producto en ese momento en el tiempo. En eleventa 5 el comportamiento es que en la tabla de articulos se replican todas las propiedades del producto lo cual es muy ineficiente debido a que si un producto rara vez cambia cualquiera de sus propiedades estamos replicando su información muchísimas veces (puesto que un producto se vende muchas más veces de las que se modifica) por ello necesitamos un mecanismo que nos permita evitar la duplicidad de datos y volver el almacenamiento de articulo más eficiente.

# Decisión

Decidimos crear una tabla llamada `PRODUCTOS_VERSIONES` en la que se creará un registro con todas las propiedades cada vez que se cree o modifique un producto, estos registros nunca serán modificados o eliminados. Al mismo tiempo agregamos el campo `VERSION_ACTUAL_UID` dentro de la tabla `PRODUCTOS` la cual siempre apunta a la versión más reciente o en uso del producto.

De esta manera, al momento de crear y almacenar un artículo de una venta cobrada, solo apuntamos al UID de la versión del producto que contiene todas las propiedades que se tenían del producto al momento de la venta.

# Consecuencias

- Debemos contemplar, para cualquier reporte el consultar la version UID del producto.
- Se debe refactorizar la lógica del módulo de productos para que se cree la versión cada vez que se cree o modifique esta entidad.
