import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';

class RepositorioVentas extends Repositorio implements IRepositorioVentas {
  final tablaVentasEnProgreso = 'ventas_en_progreso';
  final tablaArticulosVentaEnProgreso = 'ventas_en_progreso_articulos';

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
      await adaptadorSync.sincronizar(
        dataset: 'ventas_articulos',
        rowID: articulo.uid.toString(),
        fields: {
          'venta_uid': venta.uid.toString(),
          'producto_uid': articulo.producto.uid.toString(),
          'cantidad': articulo.cantidad,
          'precio_venta': articulo.precioDeVenta.serialize(),
          'descripcion': articulo.descripcion,
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
      final command = '''
          INSERT INTO $tablaArticulosVentaEnProgreso (uid, venta_uid, agregado_en, producto_uid, precio_venta,
            descripcion, cantidad) values(?,?,?,?,?,?,?);
          ''';

      await db.command(sql: command, params: [
        articulo.uid.toString(),
        venta.uid.toString(),
        articulo.agregadoEn.millisecondsSinceEpoch,
        articulo.producto.uid.toString(),
        articulo.precioDeVenta.serialize(),
        articulo.descripcion,
        articulo.cantidad
      ]);
    }
  }

  @override
  Future<void> eliminarVentaEnProgreso(UID uid) async {
    var sql = 'DELETE FROM $tablaArticulosVentaEnProgreso WHERE venta_uid = ?;';

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
