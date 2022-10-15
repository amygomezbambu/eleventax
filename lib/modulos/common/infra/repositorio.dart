import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:meta/meta.dart';

class Repositorio {
  @protected
  late IAdaptadorDeBaseDeDatos db;
  @protected
  late ISync adaptadorSync;

  Repositorio(this.adaptadorSync, this.db);

  /// Obtiene un mapa con las diferencias entre la entidad modificada y la entidad en la db
  ///
  /// [camposEntidad] representa el estado en memoria
  /// [camposDb] representa el estado almacenado en la base de datos
  Future<Map<String, Object?>> obtenerDiferencias(
    Map<String, Object?> camposEntidad,
    Map<String, Object?> camposDb,
  ) async {
    Map<String, Object?> diferencias = {};

    for (var field in camposDb.keys) {
      if (camposEntidad[field] != camposDb[field]) {
        diferencias[field] = camposEntidad[field];
      }
    }

    return diferencias;
  }

  Future<void> transaction() async {
    await db.transaction();
  }

  Future<void> commit() async {
    await db.commit();
  }

  Future<void> rollback() async {
    await db.rollback();
  }
}
