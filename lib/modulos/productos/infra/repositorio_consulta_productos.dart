import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/infra/repositorio_consulta.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';

enum ObtenerProductos { todos, borrados, activos }

class RepositorioConsultaProductos extends RepositorioConsulta
    implements IRepositorioConsultaProductos {
  RepositorioConsultaProductos({
    required IAdaptadorDeBaseDeDatos db,
  }) : super(db);

  @override
  Future<List<Impuesto>> obtenerImpuestosParaProducto(UID productoUID) async {
    List<Impuesto> impuestos = [];

    var sql = ''' 
      SELECT pi.impuesto_uid, i.nombre, i.porcentaje FROM productos_impuestos pi
      JOIN impuestos i on i.uid = pi.impuesto_uid 
      WHERE pi.producto_uid = ?;
    ''';

    var dbResult = await db.query(sql: sql, params: [productoUID.toString()]);

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        impuestos.add(Impuesto.cargar(
            uid: UID.fromString(row['impuesto_uid'] as String),
            nombre: row['nombre'] as String,
            porcentaje: (row['porcentaje'] as int).toDouble()));
      }
    }

    return impuestos;
  }

  @override
  Future<List<Impuesto>> obtenerImpuestos() async {
    List<Impuesto> res = [];
    var dbResult =
        await db.query(sql: 'SELECT uid, nombre, porcentaje FROM impuestos;');

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        res.add(Impuesto.cargar(
            uid: UID.fromString(row['uid'] as String),
            nombre: row['nombre'] as String,
            porcentaje: (row['porcentaje'] as int).toDouble()));
      }
    }

    return res;
  }

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    List<Categoria> categorias = [];

    var dbResult =
        await db.query(sql: 'SELECT uid, nombre FROM productos_categorias;');

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        categorias.add(
          Categoria.cargar(
            uid: UID.fromString(row['uid'] as String),
            nombre: row['nombre'] as String,
          ),
        );
      }
    }

    return categorias;
  }

  @override
  Future<List<UnidadDeMedida>> obtenerUnidadesDeMedida() async {
    List<UnidadDeMedida> res = [];
    var dbResult = await db.query(
        sql: 'SELECT uid, nombre, abreviacion FROM unidades_medida;');

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        res.add(UnidadDeMedida.cargar(
            uid: UID.fromString(row['uid'] as String),
            nombre: row['nombre'] as String,
            abreviacion: row['abreviacion'] as String));
      }
    }

    return res;
  }

  @override
  Future<bool> existeProducto(String codigo) async {
    var dbResult = await db.query(
      sql:
          'SELECT COUNT(codigo) as existe FROM productos where codigo = ? and borrado = ?;',
      params: [codigo, false],
    );

    var existe = dbResult[0]['existe'] as int;
    return existe >= 1;
  }

  //TODO: decidir como vamos a probar que funcionen los filtros, e2e o
  @override
  Future<List<Producto>> obtenerProductos(
      [ObtenerProductos filtro = ObtenerProductos.activos]) async {
    var condicion = '';
    switch (filtro) {
      case ObtenerProductos.todos:
        break;
      case ObtenerProductos.borrados:
        condicion += ' WHERE borrado = true ';
        break;
      case ObtenerProductos.activos:
        condicion += ' WHERE borrado = false ';
        break;
    }

    return _obtenerProductos(condicion, []);
  }

  @override
  Future<Producto?> obtenerProducto(UID uid) async {
    var productos =
        await _obtenerProductos('WHERE p.uid = ?', [uid.toString()]);

    if (productos.isEmpty) {
      return null;
    } else {
      return productos.first;
    }
  }

  Future<List<Producto>> _obtenerProductos(
      String condicionWhere, List<Object?> params) async {
    var query = '''
        SELECT p.uid,p.codigo,p.nombre,p.categoria_uid,p.precio_compra,p.precio_venta,
        p.se_vende_por,p.url_imagen,
        c.uid AS categoria_uid, c.nombre AS categoria,
        um.nombre as unidad_medida_nombre, um.abreviacion as unidad_medida_abreviacion, um.uid AS unidad_medida_uid,  
        p.preguntar_precio
        FROM productos p 
        LEFT JOIN productos_categorias c on p.categoria_uid = c.uid 
        LEFT JOIN unidades_medida um on p.unidad_medida_uid = um.uid 
        $condicionWhere''';

    var result = await db.query(sql: query, params: params);

    List<Producto> resultado = [];

    for (var row in result) {
      var impuestos = await obtenerImpuestosParaProducto(
          UID.fromString(row['uid'] as String));

      resultado.add(
        Producto.cargar(
          uid: UID.fromString(row['uid'] as String),
          nombre: NombreProducto(row['nombre'] as String),
          precioDeVenta: PrecioDeVentaProducto(
              Moneda.fromMonedaInt(row['precio_venta'] as int)),
          precioDeCompra: PrecioDeCompraProducto(
            Moneda.fromMonedaInt(row['precio_compra'] as int),
          ),
          codigo: CodigoProducto(row['codigo'] as String),
          unidadDeMedida: UnidadDeMedida.cargar(
            uid: UID.fromString(row['unidad_medida_uid'] as String),
            nombre: row['unidad_medida_nombre'] as String,
            abreviacion: row['unidad_medida_abreviacion'] as String,
          ),
          seVendePor: ProductoSeVendePor.values[row['se_vende_por'] as int],
          categoria: row['categoria_uid'] == null
              ? null
              : Categoria.cargar(
                  uid: UID.fromString(row['categoria_uid'] as String),
                  nombre: row['categoria'] as String),
          imagenURL: row['url_imagen'] as String,
          preguntarPrecio: Utils.db.intToBool(row['preguntar_precio'] as int),
          impuestos: impuestos,
        ),
      );
    }

    return resultado;
  }
}
