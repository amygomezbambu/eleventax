import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';

class RepositorioVentas extends Repositorio implements IRepositorioVentas {
  //final IRepositorioConsultaVentas _consultas;
  final tablaVentasEnProgreso = 'ventas_en_progreso';
  final tablaArticulosVentaEnProgreso = 'ventas_en_progreso_articulos';

  RepositorioVentas({
    required ISync syncAdapter,
    required IRepositorioConsultaVentas consultas,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(syncAdapter, db);

  @override
  Future<void> agregar(Venta venta) async {
    if (venta.estado == EstadoDeVenta.enProgreso) {
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
          INSERT INTO $tablaArticulosVentaEnProgreso (uid, agregado_en, producto_uid, precio_venta,
            descripcion, cantidad) values(?,?,?,?,?,?);
          ''';

        await db.command(sql: command, params: [
          articulo.uid.toString(),
          articulo.agregadoEn.millisecondsSinceEpoch,
          articulo.producto?.uid.toString(),
          articulo.precioDeVenta.serialize(),
          articulo.descripcion,
          articulo.cantidad
        ]);
      }
    } else {}
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
}
