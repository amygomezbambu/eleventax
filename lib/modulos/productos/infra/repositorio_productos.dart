import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/mapper/producto_mapper.dart';

class RepositorioProductos extends Repositorio
    implements IRepositorioProductos {
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
        'codigo': producto.codigo,
        'nombre': producto.nombre,
        'categoria': producto.categoria,
        'precio_compra': producto.precioDeCompra,
        'precio_venta': producto.precioDeVenta,
        'se_vende_por': producto.seVendePor.index,
        'url_imagen': producto.imagenURL,
      },
    );
  }

  @override
  Future<Producto?> obtener(UID uid) async {
    var query =
        'SELECT uid,codigo,nombre,categoria,precio_compra,precio_venta,se_vende_por,url_imagen '
        'FROM productos WHERE uid = ?';

    var result = await db.query(sql: query, params: [uid.toString()]);

    Producto? item;

    //TODO: usar unidad de medida real
    for (var row in result) {
      item = Producto.cargar(
        uid: UID(row['uid'] as String),
        nombre: row['nombre'] as String,
        precioDeVenta: row['precio_venta'] as double,
        precioDeCompra: row['precio_compra'] as double,
        codigo: row['codigo'] as String,
        unidadDeMedida: UnidadDeMedida(
          uid: UID(),
          nombre: 'Pieza',
          abreviacion: 'pza',
        ),
        seVendePor: ProductoSeVendePor.values[row['se_vende_por'] as int],
        categoria: row['categoria'] as String,
        imagenURL: row['url_imagen'] as String,
      );
    }

    return item;
  }

  @override
  Future<List<Producto>> obtenerTodos() async {
    var query =
        'SELECT uid,codigo,nombre,categoria,precio_compra,precio_venta,se_vende_por,url_imagen '
        'FROM productos';

    var result = await db.query(sql: query);
    var items = <Producto>[];

    for (var row in result) {
      items.add(
        Producto.cargar(
          uid: UID(row['uid'] as String),
          nombre: row['nombre'] as String,
          precioDeVenta: row['precio_venta'] as double,
          precioDeCompra: row['precio_compra'] as double,
          codigo: row['codigo'] as String,
          unidadDeMedida: UnidadDeMedida(
            uid: UID(),
            nombre: 'Pieza',
            abreviacion: 'pza',
          ),
          seVendePor: ProductoSeVendePor.values[row['se_vende_por'] as int],
          categoria: row['categoria'] as String,
          imagenURL: row['url_imagen'] as String,
        ),
      );
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
      sql:
          'SELECT uid,codigo,nombre,categoria,precio_compra,precio_venta,se_vende_por,url_imagen '
          'FROM productos WHERE uid = ?',
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
