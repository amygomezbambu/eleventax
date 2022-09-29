import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/sync/change.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';

class SyncRepository {
  late IAdaptadorDeBaseDeDatos _db;
  final _config = SyncConfig.get();

  SyncRepository({IAdaptadorDeBaseDeDatos? db}) {
    if (db != null) {
      _db = db;
    } else {
      _db = Dependencias.infra.database();
    }
  }

  Future<void> executeCommand(String command, List<Object?> params) async {
    await _db.command(sql: command, params: params);
  }

  Future<void> saveCurrentHLC(String hlc) async {
    var command = 'update syncConfig set hlc = ?;';

    await _db.command(sql: command, params: [hlc]);
  }

  Future<void> deleteMerkle() async {
    var command = 'update syncConfig set merkle = ?;';
    await _db.command(sql: command, params: ['']);
  }

  Future<void> saveMerkle(String serializedMerkle) async {
    var command = 'update syncConfig set merkle = ?;';

    await _db.command(sql: command, params: [serializedMerkle]);
  }

  Future<String> getMerkle() async {
    var merkle = '';

    var query = 'SELECT merkle FROM syncConfig;';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      merkle = dbRow['merkle'] as String;
    }

    return merkle;
  }

  Future<int> dbVersion() async {
    var version = 0;

    var query =
        'SELECT ${_config.dbVersionField} FROM ${_config.dbVersionTable};';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      version = dbRow[_config.dbVersionField] as int;
    }

    return version;
  }

  Future<String> getCurrentHLC() async {
    var hlc = '';

    var query = 'SELECT hlc FROM syncConfig;';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      hlc = dbRow['hlc'] as String;
    }

    return hlc;
  }

  Future<bool> rowExist(String dataset, String rowId) async {
    var exist = false;
    var query = 'select count(uid) as count from $dataset where uid = ?;';

    var dbResult = await _db.query(sql: query, params: [rowId]);

    if (dbResult.isNotEmpty) {
      var count = dbResult[0]['count'] as int;

      if (count > 0) {
        exist = true;
      }
    }

    return exist;
  }

  Future<List<Change>> getRowChanges(String rowId) async {
    var query = 'select dataset,rowId,column,value,type,hlc,version '
        'from crdt where rowId = ?';
    var rowChanges = <Change>[];

    var dbResult = await _db.query(sql: query, params: [rowId]);

    for (var dbRow in dbResult) {
      var change = Change.load(
          column: dbRow['column'] as String,
          value: dbRow['value'] as String,
          dataset: dbRow['dataset'] as String,
          rowId: dbRow['rowId'] as String,
          hlc: dbRow['hlc'] as String,
          version: dbRow['version'] as int);

      rowChanges.add(change);
    }

    return rowChanges;
  }

  /// Obtiene los cambios mas actuales que [change]
  ///
  /// un cambio mas nuevo es aquel que tiene el mismo rowId(misma entidad)
  /// afecta a la misma columna(campo) y tiene un hlc mayor(es mas actual)
  Future<int> getNewerChangesCount(Change change) async {
    var count = 0;

    var query = 'select count(hlc) as count from crdt where rowId = ? '
        'and column = ? and hlc > ?';

    var dbResult = await _db
        .query(sql: query, params: [change.rowId, change.column, change.hlc]);

    if (dbResult.isNotEmpty) {
      count = dbResult[0]['count'] as int;
    }

    return count;
  }

  Future<List<Change>> getUnappliedChanges() async {
    var changes = <Change>[];

    var query = 'select dataset,rowId,column,value,type,hlc,version from crdt '
        'where applied = 0';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      var change = Change.load(
          column: dbRow['column'] as String,
          value: dbRow['value'] as String,
          dataset: dbRow['dataset'] as String,
          rowId: dbRow['rowId'] as String,
          hlc: dbRow['hlc'] as String,
          version: dbRow['version'] as int);

      changes.add(change);
    }

    return changes;
  }

  Future<List<Change>> getAll() async {
    var changes = <Change>[];

    var query = 'select dataset,rowId,column,value,type,hlc,version from crdt';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      var change = Change.load(
          column: dbRow['column'] as String,
          value: dbRow['value'] as String,
          dataset: dbRow['dataset'] as String,
          rowId: dbRow['rowId'] as String,
          hlc: dbRow['hlc'] as String,
          version: dbRow['version'] as int);

      changes.add(change);
    }

    return changes;
  }

  Future<Change?> getByHLC(String hlc) async {
    Change? change;

    var query = 'select * from crdt where hlc = ?';

    var dbResult = await _db.query(sql: query, params: [hlc]);

    for (var dbRow in dbResult) {
      change = Change.load(
          column: dbRow['column'] as String,
          value: dbRow['value'] as String,
          dataset: dbRow['dataset'] as String,
          rowId: dbRow['rowId'] as String,
          hlc: dbRow['hlc'] as String,
          version: dbRow['version'] as int);
    }

    return change;
  }

  Future<void> add(Change change) async {
    await _db.command(
        sql:
            'insert into crdt(hlc,dataset,rowId,column,value,type,isLocal,sended,applied,version) '
            'values(?,?,?,?,?,?,?,?,?,?);',
        params: [
          change.hlc,
          change.dataset,
          change.rowId,
          change.column,
          (change.value is bool)
              ? Utils.db.boolToInt(change.value as bool)
              : change.value,
          change.valueType,
          1,
          0,
          0,
          change.version
        ]);
  }

  Future<void> updateAppliedChange(Change change) async {
    await _db.command(
        sql: 'update crdt set applied = 1 where hlc = ?', params: [change.hlc]);
  }
}
