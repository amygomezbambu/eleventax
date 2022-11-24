import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/sync/change.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/unique_duplicate.dart';

class SyncRepository implements IRepositorioSync {
  late IAdaptadorDeBaseDeDatos _db;

  SyncRepository({IAdaptadorDeBaseDeDatos? db}) {
    if (db != null) {
      _db = db;
    } else {
      _db = Dependencias.infra.database();
    }
  }

  @override
  Future<void> ejecutarComandoRaw(String command, List<Object?> params) async {
    await _db.command(sql: command, params: params);
  }

  @override
  Future<Map<String, String>?> obtenerCRDTPorDatos(
    String dataset,
    String column,
    String value,
    String excluirUID,
  ) async {
    var rowId = '';
    var hlc = '';

    var query = 'select dataset,rowId,hlc '
        'from crdt where dataset = ? and column = ? and value = ? '
        'and rowId != ?;';

    var dbResult = await _db.query(sql: query, params: [
      dataset,
      column,
      value,
      excluirUID,
    ]);

    for (var dbRow in dbResult) {
      rowId = dbRow['rowId'] as String;
      hlc = dbRow['hlc'] as String;
    }

    if (rowId.isEmpty) {
      return null;
    }

    return {
      'rowId': rowId,
      'hlc': hlc,
    };
  }

  @override
  Future<void> actualizarHLCActual(String hlc) async {
    var command = 'update syncConfig set hlc = ?;';

    await _db.command(sql: command, params: [hlc]);
  }

  @override
  Future<void> borrarMerkle() async {
    var command = 'update syncConfig set merkle = ?;';
    await _db.command(sql: command, params: ['']);
  }

  @override
  Future<void> actualizarMerkle(String serializedMerkle) async {
    var command = 'update syncConfig set merkle = ?;';

    await _db.command(sql: command, params: [serializedMerkle]);
  }

  @override
  Future<String> obtenerMerkle() async {
    var merkle = '';

    var query = 'SELECT merkle FROM syncConfig;';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      merkle = dbRow['merkle'] as String;
    }

    return merkle;
  }

  Future<UniqueDuplicate> obtenerDuplicadoPorSucedioPrimero(
      String uidSucedioPrimero) async {
    UniqueDuplicate duplicate;

    var query =
        'SELECT uid,dataset,column,sucedio_primero,sucedio_despues FROM sync_duplicados '
        'WHERE sucedio_primero = ?';

    var dbResult = await _db.query(sql: query, params: [uidSucedioPrimero]);

    if (dbResult.isNotEmpty) {
      duplicate = UniqueDuplicate(
          uid: dbResult[0]['uid'] as String,
          happenLastUID: dbResult[0]['sucedio_despues'] as String,
          happenFirstUID: dbResult[0]['sucedio_primero'] as String,
          dataset: dbResult[0]['dataset'] as String,
          column: dbResult[0]['column'] as String);
    } else {
      throw EleventaEx(
          message:
              'No existe un elemento para el uid proporcionado: $uidSucedioPrimero');
    }

    return duplicate;
  }

  @override
  Future<UniqueDuplicate> obtenerDuplicado(String uid) async {
    UniqueDuplicate duplicate;

    var query =
        'SELECT dataset,column,sucedio_primero,sucedio_despues FROM sync_duplicados '
        'WHERE uid = ?';

    var dbResult = await _db.query(sql: query, params: [uid]);

    if (dbResult.isNotEmpty) {
      duplicate = UniqueDuplicate(
          uid: uid,
          happenLastUID: dbResult[0]['sucedio_despues'] as String,
          happenFirstUID: dbResult[0]['sucedio_primero'] as String,
          dataset: dbResult[0]['dataset'] as String,
          column: dbResult[0]['column'] as String);
    } else {
      throw EleventaEx(
          message: 'No existe un elemento para el uid proporcionado: $uid');
    }

    return duplicate;
  }

  @override
  Future<int> obtenerVersionDeDB() async {
    var version = 0;

    var query =
        'SELECT ${syncConfig?.dbVersionField} FROM ${syncConfig?.dbVersionTable};';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      version = dbRow[syncConfig?.dbVersionField] as int;
    }

    return version;
  }

  @override
  Future<String> obtenerHLCActual() async {
    var hlc = '';

    var query = 'SELECT hlc FROM syncConfig;';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      hlc = dbRow['hlc'] as String;
    }

    return hlc;
  }

  @override
  Future<bool> existeRow(String dataset, String rowId) async {
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

  @override
  Future<List<Change>> obtenerCambiosParaRow(String rowId) async {
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
  @override
  Future<int> obtenerNumeroDeCambiosMasRecientes(Change change) async {
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

  @override
  Future<List<Change>> obtenerCambiosNoAplicados() async {
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

  @override
  Future<List<Change>> obtenerTodosLosCambios() async {
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

  @override
  Future<Change?> obtenerCambioPorHLC(String hlc) async {
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

  @override
  Future<void> agregarCambio(Change change) async {
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

  @override
  Future<void> marcarCambioComoAplicado(Change change) async {
    await _db.command(
        sql: 'update crdt set applied = 1 where hlc = ?', params: [change.hlc]);
  }
}
