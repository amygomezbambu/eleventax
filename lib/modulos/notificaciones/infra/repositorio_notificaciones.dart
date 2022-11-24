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

  @override
  Future<void> actualizar(Entidad entity) {
    // TODO: implement actualizar
    throw UnimplementedError();
  }

  @override
  Future<void> agregar(Notificacion entity) {
    // TODO: implement agregar
    throw UnimplementedError();
  }

  @override
  Future<Notificacion?> obtener(UID uid) {
    // TODO: implement obtener
    throw UnimplementedError();
  }

  @override
  Future<List<Notificacion>> obtenerTodos() {
    // TODO: implement obtenerTodos
    throw UnimplementedError();
  }

  @override
  Future<bool> existe(UID uid) {
    // TODO: implement existe
    throw UnimplementedError();
  }

  @override
  Future<void> eliminar(UID id) {
    // TODO: implement eliminar
    throw UnimplementedError();
  }

  @override
  Future<void> modificar(Notificacion entity) {
    // TODO: implement modificar
    throw UnimplementedError();
  }
}
