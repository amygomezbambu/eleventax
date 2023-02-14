import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/infra/repositorio_consulta.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/dto/producto_dto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';

enum ObtenerProductos { todos, borrados, activos }

class RepositorioConsultaProductos extends RepositorioConsulta
    implements IRepositorioConsultaProductos {
  RepositorioConsultaProductos({
    required IAdaptadorDeBaseDeDatos db,
    required ILogger logger,
  }) : super(db, logger);

  @override
  Future<List<Impuesto>> obtenerImpuestosParaProducto(UID productoUID) async {
    List<Impuesto> impuestos = [];

    const sql = ''' 
      SELECT pi.impuesto_uid, i.nombre, i.porcentaje, i.orden, i.activo FROM productos_impuestos pi
      JOIN impuestos i on i.uid = pi.impuesto_uid 
      WHERE pi.producto_uid = ? and pi.borrado = false 
    ''';

    var dbResult = await query(sql: sql, params: [productoUID.toString()]);

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        impuestos.add(Impuesto.cargar(
          uid: UID.fromString(row['impuesto_uid'] as String),
          nombre: row['nombre'] as String,
          porcentaje: (row['porcentaje'] as int).toDouble(),
          ordenDeAplicacion: (row['orden'] as int),
          activo: Utils.db.intToBool(row['activo'] as int),
        ));
      }
    }

    return impuestos;
  }

  @override
  Future<List<Impuesto>> obtenerImpuestos({bool soloActivos = true}) async {
    List<Impuesto> res = [];
    var dbResult = await query(
        sql: 'SELECT i.uid, i.nombre, i.porcentaje,  i.orden, i.activo '
            'FROM impuestos i '
            'WHERE i.borrado=false and i.Activo= ? ;',
        params: [soloActivos]);

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        res.add(Impuesto.cargar(
            uid: UID.fromString(row['uid'] as String),
            nombre: row['nombre'] as String,
            porcentaje: (row['porcentaje'] as int).toDouble(),
            ordenDeAplicacion: (row['orden'] as int),
            activo: Utils.db.intToBool(row['activo'] as int)));
      }
    }

    return res;
  }

  //TODO: estudiar si es posible no usar borrado logico, es decir usar borrado real
  @override
  Future<List<Categoria>> obtenerCategorias(
      [bool incluirBorrados = false]) async {
    List<Categoria> categorias = [];

    var dbResult = await query(
      sql: 'SELECT uid, nombre, borrado FROM categorias WHERE borrado = ?;',
      params: [incluirBorrados],
    );

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        categorias.add(
          Categoria.cargar(
            uid: UID.fromString(row['uid'] as String),
            nombre: NombreCategoria(row['nombre'] as String),
            eliminado: Utils.db.intToBool(row['borrado'] as int),
          ),
        );
      }
    }

    return categorias;
  }

  @override
  Future<List<UnidadDeMedida>> obtenerUnidadesDeMedida() async {
    List<UnidadDeMedida> res = [];
    var dbResult = await query(
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
    var dbResult = await query(
      sql:
          'SELECT COUNT(codigo) as existe FROM productos where codigo = ? and borrado = ?;',
      params: [codigo, false],
    );

    var existe = dbResult[0]['existe'] as int;
    return existe >= 1;
  }

  @override
  Future<List<Producto>> obtenerProductos(
      [ObtenerProductos filtro = ObtenerProductos.activos]) async {
    var condicion = '';
    switch (filtro) {
      case ObtenerProductos.todos:
        break;
      case ObtenerProductos.borrados:
        condicion += ' WHERE p.borrado = true ';
        break;
      case ObtenerProductos.activos:
        condicion += ' WHERE p.borrado = false ';
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

  //  uid TEXT PRIMARY KEY,
  //
  //         nombre TEXT NULL,
  //         precio_compra INTEGER NULL,
  //         precio_venta INTEGER NULL DEFAULT 0,
  //         categoria_uid TEXT NULL,
  //         unidad_medida_nombre TEXT NULL,
  //
  //         se_vende_por INTEGER NULL

  @override
  Future<ProductoDto?> obtenerVersionDeProducto(UID versionUid) async {
    ProductoDto? version;

    var sql = ''' 
      SELECT * FROM productos_versiones WHERE uid = ?;
    ''';

    final dbResult = await query(sql: sql, params: [versionUid.toString()]);

    if (dbResult.isNotEmpty) {
      var row = dbResult[0];

      version = ProductoDto();
      version.productoUid = row['producto_uid'] as String;
      version.codigo = row['codigo'] as String;
      version.codigo = row['codigo'] as String;
      version.imagenURL = row['url_imagen'] as String;
      version.nombre = row['nombre'] as String;
      version.nombreCategoria = row['categoria_nombre'] != null
          ? row['categoria_nombre'] as String
          : '';
      version.precioDeCompra = Moneda.deserialize(row['precio_compra'] as int);
      version.precioDeVenta = Moneda.deserialize(row['precio_venta'] as int);
      version.seVendePor =
          ProductoSeVendePor.values[row['se_vende_por'] as int];
      version.uid = version.uid;
      version.unidadDeMedida.nombre = row['unidad_medida_nombre'] as String;
      version.unidadDeMedida.abreviacion =
          row['unidad_medida_abreviacion'] as String;
      version.creadoEn =
          DateTime.fromMillisecondsSinceEpoch(row['guardado_en'] as int);
    }

    return version;
  }

  @override
  Future<Producto?> obtenerProductoPorCodigo(CodigoProducto codigo) async {
    var productos =
        await _obtenerProductos('WHERE p.codigo = ?', [codigo.value]);

    if (productos.isEmpty) {
      return null;
    } else {
      return productos.first;
    }
  }

  Future<List<Producto>> _obtenerProductos(
      String condicionWhere, List<Object?> params) async {
    var sql = '''
        SELECT p.uid,p.codigo,p.nombre,p.categoria_uid,p.precio_compra,p.precio_venta,
        p.se_vende_por,p.url_imagen, p.borrado AS eliminado, p.version_actual_uid,
        c.uid AS categoria_uid, c.nombre AS categoria_nombre, c.borrado as categoria_borrado,
        um.nombre as unidad_medida_nombre, um.abreviacion as unidad_medida_abreviacion, um.uid AS unidad_medida_uid,  
        p.preguntar_precio
        FROM productos p 
        LEFT JOIN categorias c on p.categoria_uid = c.uid   
        LEFT JOIN unidades_medida um on p.unidad_medida_uid = um.uid
        $condicionWhere  ''';

    var result = await query(sql: sql, params: params);

    List<Producto> resultado = [];

    for (var row in result) {
      var impuestos = await obtenerImpuestosParaProducto(
          UID.fromString(row['uid'] as String));

      resultado.add(
        Producto.cargar(
          uid: UID.fromString(row['uid'] as String),
          nombre: NombreProducto(row['nombre'] as String),
          precioDeVenta: PrecioDeVentaProducto(
              Moneda.deserialize(row['precio_venta'] as int)),
          precioDeCompra: PrecioDeCompraProducto(
            Moneda.deserialize(row['precio_compra'] as int),
          ),
          codigo: CodigoProducto(row['codigo'] as String),
          unidadDeMedida: UnidadDeMedida.cargar(
            uid: UID.fromString(row['unidad_medida_uid'] as String),
            nombre: row['unidad_medida_nombre'] as String,
            abreviacion: row['unidad_medida_abreviacion'] as String,
          ),
          seVendePor: ProductoSeVendePor.values[row['se_vende_por'] as int],
          categoria: (row['categoria_uid'] == null) ||
                  (Utils.db.intToBool(row['categoria_borrado'] as int) == true)
              ? null
              : Categoria.cargar(
                  uid: UID.fromString(row['categoria_uid'] as String),
                  nombre: NombreCategoria(row['categoria_nombre'] as String),
                  eliminado: false,
                ),
          imagenURL: row['url_imagen'] as String,
          preguntarPrecio: Utils.db.intToBool(row['preguntar_precio'] as int),
          impuestos: impuestos,
          eliminado: Utils.db.intToBool(row['eliminado'] as int),
          versionActual: UID.fromString(row['version_actual_uid'] as String),
        ),
      );
    }

    return resultado;
  }

  @override
  Future<UID> obtenerRelacionProductoImpuesto(
    UID productoUID,
    UID impuestoUID,
  ) async {
    var dbResult = await query(
      sql:
          'SELECT uid FROM productos_impuestos where producto_uid = ? and impuesto_uid = ?;',
      params: [
        productoUID.toString(),
        impuestoUID.toString(),
      ],
    );

    if (dbResult.isEmpty) {
      throw ValidationEx(
          tipo: TipoValidationEx.argumentoInvalido,
          mensaje: 'No existe la relacion entre el impuesto y el producto');
    }

    return UID.fromString(dbResult[0]['uid'] as String);
  }

  @override
  Future<bool> existe(UID uid) async {
    const sql = 'SELECT count(uid) as count FROM productos where uid = ?;';

    var dbResult = await query(sql: sql, params: [uid.toString()]);
    var existe = false;

    if (dbResult.isNotEmpty) {
      if ((dbResult[0]['count'] as int) > 0) {
        existe = true;
      }
    }

    return existe;
  }

  @override
  Future<bool> existeCategoria({required String nombre}) async {
    const sql =
        'SELECT count(uid) as count FROM categorias WHERE nombre = ? AND borrado = false;';

    var dbResult = await query(sql: sql, params: [nombre]);
    var existe = false;

    if (dbResult.isNotEmpty) {
      if ((dbResult[0]['count'] as int) > 0) {
        existe = true;
      }
    }

    return existe;
  }

  @override
  Future<Categoria?> obtenerCategoria(UID uid) async {
    Categoria? categoria;

    const sql = 'SELECT nombre,borrado FROM categorias WHERE uid = ?';

    var dbResult = await query(sql: sql, params: [uid.toString()]);

    if (dbResult.isNotEmpty) {
      categoria = Categoria.cargar(
        uid: uid,
        nombre: NombreCategoria(dbResult[0]['nombre'] as String),
        eliminado: Utils.db.intToBool(dbResult[0]['borrado'] as int),
      );
    }
    return categoria;
  }
}
