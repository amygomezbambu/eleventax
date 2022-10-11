# Modulo de Sincronización

## Introducción

Este modulo permite sincronizar los datos de la base de datos entre todos los dispositivos
que pertenecen a una mismo grupo(o canal), para eleventa una sucursal equivale a un grupo ya
que deseamos que solo se sincronicen datos entre los dispositivos de la misma sucursal.

## Conceptos

- grupo: todos los dispositivos que se conecten a un grupo recibiran los cambios de todos
los otros dispositivos del mismo grupo, en otros sistemas de mensajeria se le conoce como
_topico_ o _canal_, debe tener un numero al final que puede ser usado para distribuir la carga
del lado del servidor, por ejemplo: `CH-JuanEscutia-01, CH-Industrias-02`.
- cambio: la unidad basica de sincronización es el cambio, un cambio contiene los datos
de un solo campo o propiedad, si por ejemplo actualizamos un producto y cambian 5 de sus
propiedades entonces se generarán 5 cambios, uno por cada propiedad.
- dispositivo: cada dispositivo que se conecta debe proporcionar un identificador unico,
es necesario que se le de una ponderación, esto para que en caso de un
conflicto gane el dispositivo con mayor peso, por ejemplo:

`D-a13at0Ri0-0001(caja principal) , D-Al3@T0riO-0002(celular externo)`

En este caso, si llega a existir un conflicto que no se pueda resolver por medio del timestamp
ganará el que tenga menor numero.

## Como usarlo

Lo primero que se tiene que hacer es configurarlo, esto se hace en el loader:

```dart
var syncAdapter = Sync.init(
  syncConfig: SyncConfig.create(
    dbVersionTable: 'migrations',
    dbVersionField: 'version',
    groupId: 'CUU-Matriz-01',
    deviceId: appConfig.deviceId.toString(),
    addChangesEndpoint:'http://algo.com/addEndpoint',
    getChangesEndpoint:'http://algo.com/getEndpoint',
    deleteChangesEndpoint: 'http://algo.com/deleteEndpoint',
    pullInterval: 10000, //milisegundos
    onError: (ex, stack) {
        Dependencias.infra.logger().error(ex: ex, stackTrace: stack);
        throw ex;
    },
  ),
);
```

una vez configurado podemos comenzar a usarlo, como ya se habia mencionado el adaptador
de sincronización trabaja con *cambios* asi es que debemos convertir los cambios hechos
a un mapa de la siguiente manera:

```dart
//RepositorioProductos.dart
Future<void> agregar(Producto producto) async {
  await adaptadorSync.synchronize(
    dataset: 'productos', //nombre de la tabla
    rowID: producto.uid.toString(), //cada row de la tabla debe tener un id unico
    fields: { //listado de campos que se deben sincronizar
      'sku': producto.sku,
      'descripcion': producto.descripcion,
      'precio': producto.precio
    },
  );
}
```

Con esto el adaptador se encargará de persistir los datos localmente y sincronizarlos con los 
dispositivos remotos, no hay necesidad de persistir los datos en la db directamente y de hecho
esta prohibido hacerlo, nunca debemos directamente escribir o modificar datos en la DB, solo
esta permitido consultar libremente.

Si deseamos hacer un update, el repositorio base `Repositorio.dart` cuenta con un metodo
auxiliar que nos facilita obtener los cambios:

```dart
//RepositorioProductos.dart
Future<void> actualizar(Producto producto) async {
  //Obtenemos la version actual de la entidad
  var dbResult = await db.query(
    sql: 'select descripcion,precio,sku,uid from productos where uid = ?',
    params: [producto.uid.toString()],
  );

  if (dbResult.isNotEmpty) {
    //transformamos el resultado del query a una entidad
    var row = dbResult[0];
    var productoDB = ProductoMapper.databaseADomain(row);

    //este metodo obtiene el mapa con los campos que cambiaron
    var diferencias = await obtenerDiferencias(
      ProductoMapper.domainAMap(producto),
      ProductoMapper.domainAMap(productoDB),
    );

    //pasamos solo los datos que cambiaron
    await adaptadorSync.synchronize(
      dataset: 'productos',
      rowID: producto.uid.toString(),
      fields: diferencias,
    );
  } else {
    throw EleventaEx(
      message: 'No existe la entidad en la base de datos',
      input: producto.toString(),
    );
  }
}
```

Para saber mas acerca de la implementación interna del modulo de sincronización ir al
ADR Global 003. 



