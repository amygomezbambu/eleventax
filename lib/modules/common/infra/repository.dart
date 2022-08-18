import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:meta/meta.dart';

class Repository {
  @protected
  late IDatabaseAdapter db;
  @protected
  late ISync sync;

  Repository(ISync? sync, IDatabaseAdapter? db) {
    if (db != null) {
      this.db = db;
    } else {
      this.db = Dependencies.infra.database();
    }

    if (sync != null) {
      this.sync = sync;
    } else {
      this.sync = Dependencies.infra.sync();
    }
  }

  /// Obtiene un mapa con las diferencias entre la entidad modificada y la entidad en la db
  ///
  /// [inMemoryFields] representa representa el estado en memoria
  /// [dbFields] representa el estado almacenado en la base de datos
  Future<Map<String, Object?>> getDifferences(
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
