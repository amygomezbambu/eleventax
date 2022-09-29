import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/app/mapper/producto_mapper.dart';
import 'package:eleventa/modulos/productos/domain/entity/producto.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';

class RepositorioProductos extends Repositorio
    implements IRepositorioArticulos {
  RepositorioProductos({
    required ISync syncAdapter,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(syncAdapter, db);

  @override
  Future<void> agregar(Producto producto) async {
    await adaptadorSync.synchronize(
      dataset: 'productos',
      rowID: producto.uid.toString(),
      fields: {
        'sku': producto.sku,
        'descripcion': producto.descripcion,
        'precio': producto.precio
      },
    );
  }

  @override
  Future<Producto?> obtener(UID uid) async {
    var query =
        'SELECT uid, sku, descripcion, precio FROM productos WHERE uid = ?';

    var result = await db.query(sql: query, params: [uid.toString()]);
    Producto? item;

    for (var row in result) {
      item = Producto.cargar(UID(row['uid'] as String), row['sku'] as String,
          row['descripcion'] as String, row['precio'] as double);
    }

    return item;
  }

  @override
  Future<Producto?> obtenerPorSKU(String sku) async {
    var query =
        'SELECT uid, sku, descripcion, precio FROM productos WHERE sku = ?';

    var result = await db.query(sql: query, params: [sku]);
    Producto? item;

    for (var row in result) {
      item = Producto.cargar(UID(row['uid'] as String), row['sku'] as String,
          row['descripcion'] as String, double.parse(row['precio'].toString()));
    }

    return item;
  }

  @override
  Future<List<Producto>> obtenerTodos() async {
    var query = 'SELECT uid, sku, descripcion, precio FROM productos';

    var result = await db.query(sql: query);
    var items = <Producto>[];

    for (var row in result) {
      items.add(Producto.cargar(
          UID(row['uid'] as String),
          row['sku'] as String,
          row['descripcion'] as String,
          double.parse(row['precio'].toString())));
    }

    return items;
  }

  @override
  Future<void> borrar(UID id) {
    throw UnimplementedError();
  }

  @override
  Future<void> actualizar(Producto producto) async {
    var dbResult = await db.query(
      sql: 'select descripcion,precio,sku,uid from productos where uid = ?',
      params: [producto.uid.toString()],
    );

    if (dbResult.isNotEmpty) {
      var row = dbResult[0];
      var productoDB = ProductoMapper.databaseADomain(row);

      var diferencias = await obtenerDiferencias(
        ProductoMapper.domainAMap(producto),
        ProductoMapper.domainAMap(productoDB),
      );

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
}
