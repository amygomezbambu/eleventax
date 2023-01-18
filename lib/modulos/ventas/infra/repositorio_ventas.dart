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

  RepositorioVentas({
    required ISync syncAdapter,
    required IRepositorioConsultaVentas consultas,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(syncAdapter, db);

  @override
  Future<void> agregar(Venta venta) async {
    if (venta.estado == EstadoDeVenta.enProgreso) {
      final command =
          'INSERT INTO $tablaVentasEnProgreso (uid, creado_en) values(?,?);';

      await db.command(sql: command, params: [
        venta.uid.toString(),
        venta.creadoEn.millisecondsSinceEpoch,
      ]);
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
