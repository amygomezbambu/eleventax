import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto_generico.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';

class RepositorioVentas extends Repositorio implements IRepositorioVentas {
  final tablaVentasEnProgreso = 'ventas_en_progreso';
  final tablaArticulosVentaEnProgreso = 'ventas_en_progreso_articulos';
  final tablaVentasGenericosEnProgreso = 'ventas_genericos_en_progreso';
  final tablaVentasGenericosEnProgresoImpuestos =
      'ventas_genericos_en_progreso_impuestos';

  RepositorioVentas({
    required ISync adaptadorSync,
    required IRepositorioConsultaVentas consultas,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(adaptadorSync, db);

  @override
  Future<void> agregar(Venta venta) async {
    await adaptadorSync.sincronizar(
      dataset: 'ventas',
      rowID: venta.uid.toString(),
      fields: {
        'creado_en': venta.creadoEn.millisecondsSinceEpoch,
        'cobrado_en': venta.cobradaEn!.millisecondsSinceEpoch,
        'subtotal': venta.subtotal.serialize(),
        'total_impuestos': venta.totalImpuestos.serialize(),
        'folio': venta.folio,
        'estado': venta.estado.index,
        'total': venta.total.serialize(),
      },
    );

    for (var totalImpuesto in venta.totalDeImpuestos) {
      await adaptadorSync.sincronizar(
        dataset: 'ventas_impuestos',
        rowID: UID().toString(),
        fields: {
          'venta_uid': venta.uid.toString(),
          'nombre_impuesto': totalImpuesto.impuesto.nombre,
          'porcentaje_impuesto': totalImpuesto.impuesto.porcentaje.toString(),
          'base_impuesto': totalImpuesto.base.serialize(),
          'monto': totalImpuesto.monto.serialize(),
        },
      );
    }

    for (var pago in venta.pagos) {
      await adaptadorSync.sincronizar(
        dataset: 'ventas_pagos',
        rowID: UID().toString(),
        fields: {
          'venta_uid': venta.uid.toString(),
          'forma_de_pago_uid': pago.forma.uid.toString(),
          'monto': pago.monto.serialize(),
          if (pago.pagoCon != null) 'pago_con': pago.pagoCon!.serialize(),
          if (pago.referencia != null) 'referencia': pago.referencia,
        },
      );
    }

    for (var articulo in venta.articulos) {
      if (articulo.producto is ProductoGenerico) {
        await adaptadorSync.sincronizar(
          dataset: 'ventas_productos_genericos',
          rowID: articulo.producto.uid.toString(),
          fields: {
            'precio_venta': articulo.producto.precioDeVenta.serialize(),
            'nombre': articulo.producto.nombre,
          },
        );
      }

      await adaptadorSync.sincronizar(
        dataset: 'ventas_articulos',
        rowID: articulo.uid.toString(),
        fields: {
          'venta_uid': venta.uid.toString(),
          'version_producto_uid': (articulo.producto is Producto)
              ? articulo.producto.versionActual.toString()
              : '',
          'producto_generico_uid': (articulo.producto is ProductoGenerico)
              ? articulo.producto.uid.toString()
              : '',
          'cantidad': articulo.cantidad,
          // 'precio_venta': articulo.precioDeVenta.serialize(),
          'subtotal': articulo.subtotal.serialize(),
          'agregado_en': articulo.agregadoEn.millisecondsSinceEpoch,
        },
      );

      for (var totalDeImpuesto in articulo.totalesDeImpuestos) {
        await adaptadorSync.sincronizar(
          dataset: 'ventas_articulos_impuestos',
          rowID: UID().toString(),
          fields: {
            'articulo_uid': articulo.uid.toString(),
            'nombre_impuesto': totalDeImpuesto.impuesto.nombre,
            'porcentaje_impuesto':
                totalDeImpuesto.impuesto.porcentaje.toString(),
            'base_impuesto': totalDeImpuesto.base.serialize(),
            'monto': totalDeImpuesto.monto.serialize(),
          },
        );
      }
    }
  }

  @override
  Future<void> eliminar(UID id) {
    // TODO: implement eliminar
    throw UnimplementedError();
  }

  @override
  Future<void> modificar(Venta entity) {
    // TODO: implement modificar
    throw UnimplementedError();
  }

  //TODO: extraer metodos
  @override
  Future<void> agregarVentaEnProgreso(Venta venta) async {
    final command =
        'INSERT INTO $tablaVentasEnProgreso (uid, creado_en, subtotal, total_impuestos, total) '
        'VALUES(?,?, ?, ? , ?);';

    await db.command(sql: command, params: [
      venta.uid.toString(),
      venta.creadoEn.millisecondsSinceEpoch,
      venta.subtotal.serialize(),
      venta.totalImpuestos.serialize(),
      venta.total.serialize(),
    ]);

    for (var articulo in venta.articulos) {
      if (articulo.producto is ProductoGenerico) {
        var command = '''
          INSERT INTO $tablaVentasGenericosEnProgreso (uid, precio_venta, nombre) VALUES(?,?,?);
        ''';

        await db.command(sql: command, params: [
          articulo.producto.uid.toString(),
          articulo.producto.precioDeVenta.serialize(),
          articulo.producto.nombre,
        ]);

        command = '''
          INSERT INTO $tablaVentasGenericosEnProgresoImpuestos (
            producto_generico_uid, impuesto_uid) VALUES(?,?);
        ''';

        for (var impuesto in articulo.producto.impuestos) {
          await db.command(sql: command, params: [
            articulo.producto.uid.toString(),
            impuesto.uid.toString(),
          ]);
        }
      }

      final command = '''
          INSERT INTO $tablaArticulosVentaEnProgreso (
            uid, venta_uid, agregado_en, producto_generico_uid, producto_uid, precio_venta, cantidad) 
          VALUES(?,?,?,?,?,?,?);
          ''';

      await db.command(sql: command, params: [
        articulo.uid.toString(),
        venta.uid.toString(),
        articulo.agregadoEn.millisecondsSinceEpoch,
        (articulo.producto is ProductoGenerico)
            ? articulo.producto.uid.toString()
            : null,
        (articulo.producto is Producto)
            ? articulo.producto.uid.toString()
            : null,
        articulo.precioDeVenta.serialize(),
        articulo.cantidad
      ]);
    }
  }

  @override
  Future<void> eliminarVentaEnProgreso(UID uid) async {
    var sql = '''
          SELECT producto_generico_uid FROM $tablaArticulosVentaEnProgreso 
          WHERE venta_uid = ?;
        ''';
    final result = await db.query(sql: sql, params: [uid.toString()]);

    for (var row in result) {
      var productoGenericoUID = row['producto_generico_uid'] as String;

      sql =
          'DELETE FROM $tablaVentasGenericosEnProgresoImpuestos WHERE producto_generico_uid = ?;';
      await db.command(sql: sql, params: [productoGenericoUID]);

      sql = 'DELETE FROM $tablaVentasGenericosEnProgreso WHERE uid = ?;';
      await db.command(sql: sql, params: [productoGenericoUID]);
    }

    sql = 'DELETE FROM $tablaArticulosVentaEnProgreso WHERE venta_uid = ?;';

    await db.command(sql: sql, params: [uid.toString()]);

    sql = 'DELETE FROM $tablaVentasEnProgreso WHERE uid = ?;';

    await db.command(sql: sql, params: [uid.toString()]);
  }

  @override
  Future<void> modificarVentaEnProgreso(Venta venta) async {
    await eliminarVentaEnProgreso(venta.uid);
    await agregarVentaEnProgreso(venta);
  }
}
