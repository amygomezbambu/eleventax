import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/infra/repositorio_consulta.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';

class RepositorioConsultaVentas extends RepositorioConsulta
    implements IRepositorioConsultaVentas {
  RepositorioConsultaVentas(
      {required IAdaptadorDeBaseDeDatos db, required ILogger logger})
      : super(db, logger);
  @override
  Future<Venta?> obtenerVenta(UID uid) async {
    return null;
  }

  @override
  Future<Venta?> obtenerVentaEnProgreso(UID uid) async {
    Venta? venta;

    var sql = '''
        SELECT uid, estado, creado_en from ventas_en_progreso where uid = ?;
        ''';

    var result = await query(sql: sql, params: [uid]);

    // TODO: Crear un tipo de FechaBD que lea/guarde en UNIX epoc estilo Moneda
    if (result.isNotEmpty) {
      final row = result.first;
      venta = Venta.cargar(
          uid: UID.fromString(row['uid'] as String),
          estado: EstadoDeVenta.enProgreso,
          creadoEn:
              DateTime.fromMillisecondsSinceEpoch(row['creado_en'] as int),
          subtotal: Moneda.deserialize(row['subtotal'] as int),
          total: Moneda.deserialize(row['total'] as int),
          totalImpuestos: Moneda.deserialize(row['total_impuestos'] as int));
    }

    return venta;
  }
}
