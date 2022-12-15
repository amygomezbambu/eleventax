import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/notificaciones/domain/notificacion.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/notificaciones/interfaces/repositorio_notificaciones.dart';

class RepositorioNotificaciones extends Repositorio
    implements IRepositorioNotificaciones {
  RepositorioNotificaciones({
    required ISync syncAdapter,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(syncAdapter, db);

  Future<void> actualizar(Entidad entity) {
    throw UnimplementedError();
  }

  @override
  Future<void> agregar(Notificacion notificacion) async {
    await adaptadorSync.synchronize(
      dataset: 'notificaciones',
      rowID: notificacion.uid.toString(),
      fields: {
        'tipo': notificacion.tipo.index,
        'mensaje': notificacion.mensaje,
        'cuerpo': notificacion.cuerpoToJson(),
        'timestamp': notificacion.timestamp,
      },
    );
  }

  Future<Notificacion?> obtener(UID uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> eliminar(UID id) {
    throw UnimplementedError();
  }

  @override
  Future<void> modificar(Notificacion entity) {
    throw UnimplementedError();
  }
}
