import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/domain/nombre_value_object.dart';
import 'package:eleventa/modulos/common/infra/repositorio_consulta.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/articulo.dart';
import 'package:eleventa/modulos/ventas/read_models/pago.dart';
import 'package:eleventa/modulos/ventas/read_models/total_impuesto.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:eleventa/modulos/ventas/ventas_ex.dart';

class RepositorioConsultaVentas extends RepositorioConsulta
    implements IRepositorioConsultaVentas {
  final IRepositorioConsultaProductos _productos;

  final _tablaVentasEnProgreso = "ventas_en_progreso";
  final _tablaVentasEnProgresoArticulos = "ventas_en_progreso_articulos";
  final _tablaVentas = "ventas";
  final _tablaFormasDePago = "formas_de_pago";
  final _tablaVentasArticulos = "ventas_articulos";
  final _tablaVentasArticulosImpuestos = "ventas_articulos_impuestos";

  RepositorioConsultaVentas({
    required IAdaptadorDeBaseDeDatos db,
    required ILogger logger,
    required IRepositorioConsultaProductos productos,
  })  : _productos = productos,
        super(db, logger);

  Future<List<TotalImpuestoDto>> _obtenerTotalesDeImpuestosDeArticulo(
      UID uid) async {
    var totales = <TotalImpuestoDto>[];

    var sql = '''
        SELECT va.uid,
          vai.nombre_impuesto, vai.porcentaje_impuesto, vai.base_impuesto, vai.monto
        FROM $_tablaVentasArticulos va 
        LEFT JOIN $_tablaVentasArticulosImpuestos vai on vai.articulo_uid = va.uid
        WHERE va.uid = ?;
    ''';

    final dbResult = await query(sql: sql, params: [uid.toString()]);

    for (var row in dbResult) {
      var totalImpuesto = TotalImpuestoDto();
      totalImpuesto.base = Moneda.deserialize(row['base_impuesto'] as int);
      totalImpuesto.nombreImpuesto = row['nombre_impuesto'] as String;
      totalImpuesto.monto = Moneda.deserialize(row['monto'] as int);
      totalImpuesto.porcentaje =
          double.parse(row['porcentaje_impuesto'] as String);

      totales.add(totalImpuesto);
    }

    return totales;
  }

  @override
  Future<Venta?> obtenerVentaEnProgreso(UID uid) async {
    Venta? venta;

    var sql = '''
        SELECT vp.uid, vp.creado_en,vp.subtotal,vp.total,vp.total_impuestos,
          vpa.producto_uid, vpa.producto_generico_uid, vpa.cantidad,
          vpa.agregado_en, vpa.uid as articulo_uid 
        FROM $_tablaVentasEnProgreso vp 
        LEFT JOIN $_tablaVentasEnProgresoArticulos vpa ON vpa.venta_uid = vp.uid 
        WHERE vp.uid = ?;
        ''';

    List<Articulo> articulos = [];

    var result = await query(sql: sql, params: [uid.toString()]);

    if (result.isNotEmpty) {
      for (var row in result) {
        IProducto? producto;
        if (row['producto_uid'] != null) {
          producto = (await _productos
              .obtenerProducto(UID.fromString(row['producto_uid'] as String)));
        } else {
          producto = (await _productos.obtenerProductoGenericoEnProgreso(
              UID.fromString(row['producto_generico_uid'] as String)));
        }

        if (producto == null) {
          throw VentasEx(
            tipo: TiposVentasEx.productoNoExiste,
            message: 'El producto no existe',
          );
        }

        var articulo = Articulo.cargar(
          uid: UID.fromString(row['articulo_uid'] as String),
          cantidad: row['cantidad'] as double,
          agregadoEn:
              DateTime.fromMillisecondsSinceEpoch(row['agregado_en'] as int),
          producto: producto,
        );

        articulos.add(articulo);
      }

      final row = result.first;

      venta = Venta.cargar(
        uid: uid,
        estado: EstadoDeVenta.enProgreso,
        creadoEn: DateTime.fromMillisecondsSinceEpoch(row['creado_en'] as int),
        subtotal: Moneda.deserialize(row['subtotal'] as int),
        totalImpuestos: Moneda.deserialize(row['total_impuestos'] as int),
        total: Moneda.deserialize(row['total'] as int),
        articulos: articulos,
      );
    }

    return venta;
  }

  @override
  Future<String?> obtenerFolioDeVentaMasReciente() async {
    // TODO: Filtrar las ventas por MI dispositivo en base al prefijo
    final sql =
        'SELECT folio FROM $_tablaVentas ORDER BY cobrado_en DESC LIMIT 1;';

    final dbResult = await query(sql: sql);

    if (dbResult.isEmpty) {
      return null;
    } else {
      return dbResult.first['folio'] as String;
    }
  }

  @override
  Future<FormaDePago?> obtenerFormaDePago(UID uid) async {
    FormaDePago? formaDePago;

    final sql = '''
      SELECT nombre, orden, tipo, borrado, activo 
      FROM $_tablaFormasDePago  
      WHERE uid = ?''';

    final dbResult = await query(sql: sql, params: [uid.toString()]);

    if (dbResult.isNotEmpty) {
      formaDePago = FormaDePago.cargar(
        uid: UID.fromString(dbResult.first['uid'] as String),
        nombre: NombreValueObject(nombre: dbResult.first['nombre'] as String),
        orden: dbResult.first['orden'] as int,
        borrado: Utils.db.intToBool(dbResult.first['borrado'] as int),
        activo: Utils.db.intToBool(dbResult.first['activo'] as int),
        tipo: TipoFormaDePago.porAbreviacion(dbResult.first['tipo'] as String),
      );
    }

    return formaDePago;
  }

  @override
  Future<List<FormaDePago>> obtenerFormasDePago() async {
    List<FormaDePago> result = [];

    final sql = '''
      SELECT uid, nombre, orden, tipo 
      FROM $_tablaFormasDePago  
      WHERE borrado = false AND activo = true''';

    final dbResult = await query(sql: sql);

    for (var row in dbResult) {
      result.add(FormaDePago.cargar(
        uid: UID.fromString(row['uid'] as String),
        nombre: NombreValueObject(nombre: row['nombre'] as String),
        orden: row['orden'] as int,
        borrado: false,
        activo: true,
        tipo: TipoFormaDePago.porAbreviacion(row['tipo'] as String),
      ));
    }

    return result;
  }

  @override
  Future<VentaDto?> obtenerVenta(UID uid) async {
    VentaDto? venta;
    List<ArticuloDto> articulos = [];

    var sql = '''
        SELECT v.uid, v.estado, v.creado_en, v.total, v.subtotal, v.total_impuestos, 
        v.cobrado_en, v.folio, va.producto_generico_uid,
        va.uid as articulo_uid, va.cantidad,
        pv.nombre AS producto_nombre, pv.precio_venta AS producto_precio_venta,
        g.nombre AS generico_nombre, g.precio_venta AS generico_precio_venta,
        va.agregado_en, va.version_producto_uid, va.subtotal as subtotal_articulo
        FROM $_tablaVentas v 
          JOIN $_tablaVentasArticulos va on va.venta_uid = v.uid     
        LEFT JOIN productos_versiones pv ON pv.uid = va.version_producto_uid         
        LEFT JOIN ventas_productos_genericos g ON g.uid = va.producto_generico_uid  
        WHERE v.uid = ?;
        ''';

    var result = await query(sql: sql, params: [uid.toString()]);

    if (result.isNotEmpty) {
      for (var row in result) {
        var articulo = ArticuloDto();
        articulo.uid = row['articulo_uid'] as String;
        articulo.versionProductoUID = row['version_producto_uid'] as String;
        articulo.cantidad = row['cantidad'] as double;
        articulo.agregadoEn =
            DateTime.fromMillisecondsSinceEpoch(row['agregado_en'] as int);

        articulo.esGenerico = row['producto_generico_uid'] != null;

        if ((row['producto_generico_uid'] as String).isNotEmpty) {
          articulo.precioDeVenta =
              Moneda.deserialize(row['generico_precio_venta'] as int);
          articulo.productoNombre = row['generico_nombre'] as String;
        } else {
          articulo.precioDeVenta =
              Moneda.deserialize(row['producto_precio_venta'] as int);
          articulo.productoNombre = row['producto_nombre'] as String;
        }

        articulo.subtotal = Moneda.deserialize(row['subtotal_articulo'] as int);
        articulo.totalesDeImpuestos =
            await _obtenerTotalesDeImpuestosDeArticulo(
                UID.fromString(articulo.uid));

        articulos.add(articulo);
      }

      final row = result.first;

      venta = VentaDto();
      venta.uid = row['uid'] as String;
      venta.estado = EstadoDeVenta.values[row['estado'] as int];
      venta.creadoEn =
          DateTime.fromMillisecondsSinceEpoch(row['creado_en'] as int);
      venta.subtotal = Moneda.deserialize(row['subtotal'] as int);
      venta.totalImpuestos = Moneda.deserialize(row['total_impuestos'] as int);
      venta.total = Moneda.deserialize(row['total'] as int);
      venta.folio = row['folio'] as String;
      venta.articulos = articulos;

      if (row['cobrado_en'] != null) {
        venta.cobradaEn =
            DateTime.fromMillisecondsSinceEpoch(row['creado_en'] as int);
      }

      sql = '''
      SELECT monto, pago_con, referencia, fp.nombre 
      FROM ventas_pagos vp 
        JOIN formas_de_pago fp ON vp.forma_de_pago_uid = fp.uid
      WHERE vp.venta_uid = ?
      ''';

      result = await query(sql: sql, params: [uid.toString()]);

      for (var row in result) {
        var pago = PagoDto();
        pago.forma = row['nombre'] as String;
        pago.monto = Moneda.deserialize(row['monto'] as int);
        pago.pagoCon = row['pago_con'] != null
            ? Moneda.deserialize(row['pago_con'] as int)
            : null;
        pago.referencia =
            row['referencia'] != null ? row['referencia'] as String : null;

        venta.pagos.add(pago);
      }

      sql = '''
      SELECT nombre_impuesto, porcentaje_impuesto, base_impuesto, monto 
      FROM ventas_impuestos 
      WHERE venta_uid = ?
      ''';

      result = await query(sql: sql, params: [uid.toString()]);

      for (var row in result) {
        var impuesto = TotalImpuestoDto();
        impuesto.nombreImpuesto = row['nombre_impuesto'] as String;
        impuesto.porcentaje =
            double.parse(row['porcentaje_impuesto'] as String);
        impuesto.base = Moneda.deserialize(row['base_impuesto'] as int);
        impuesto.monto = Moneda.deserialize(row['monto'] as int);

        venta.totalesDeImpuestos.add(impuesto);
      }
    }

    return venta;
  }
}
