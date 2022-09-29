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
  /// [inMemoryFields] representa representa el estado en memoria
  /// [dbFields] representa el estado almacenado en la base de datos
  Future<Map<String, Object?>> obtenerDiferencias(
    Map<String, Object?> inMemoryFields,
    Map<String, Object?> dbFields,
  ) async {
    Map<String, Object?> differences = {};

    for (var field in dbFields.keys) {
      if (inMemoryFields[field] != dbFields[field]) {
        differences[field] = inMemoryFields[field];
      }
    }

    return differences;
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
