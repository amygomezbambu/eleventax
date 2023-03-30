import 'dart:convert';

import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/entity/queue_entry.dart';
import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/entity/unique_duplicate.dart';
import 'package:hlc/hlc.dart';

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
    String uidExcluido,
  ) async {
    var rowId = '';
    var hlc = '';

    var query = '''
        SELECT c.dataset,c.rowId,c.hlc 
        FROM crdt c
        JOIN crdt_campos cc ON c.hlc = cc.crdt_hlc
        WHERE c.dataset = ? and cc.nombre = ? and cc.valor = ? 
        and c.rowId != ?;
        ''';

    var dbResult = await _db.query(sql: query, params: [
      dataset,
      column,
      value,
      uidExcluido,
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
      throw SyncEx(
          tipo: TiposSyncEx.errorGenerico,
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
      throw SyncEx(
          tipo: TiposSyncEx.errorGenerico,
          message: 'No existe un elemento para el uid proporcionado: $uid');
    }

    return duplicate;
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
  Future<int> obtenerUltimaFechaDeSincronizacion() async {
    var epoch = 0;

    var query = 'SELECT ultima_sincronizacion FROM syncConfig;';

    var dbResult = await _db.query(sql: query);

    for (var dbRow in dbResult) {
      epoch = dbRow['ultima_sincronizacion'] as int;
    }

    return epoch;
  }

  @override
  Future<bool> existeRow(String dataset, String rowId) async {
    var exist = false;
    var query = 'SELECT count(uid) AS count FROM $dataset WHERE uid = ?;';

    var dbResult = await _db.query(sql: query, params: [rowId]);

    if (dbResult.isNotEmpty) {
      var count = dbResult[0]['count'] as int;

      if (count > 0) {
        exist = true;
      }
    }

    return exist;
  }

  /// Obtiene los cambios mas actuales que [change]
  ///
  /// un cambio mas nuevo es aquel que tiene el mismo rowId(misma entidad)
  /// afecta a la misma columna(campo) y tiene un hlc mayor(es mas actual)
  @override
  Future<int> obtenerNumeroDeCambiosMasRecientesParaCampo(
    EventoSync evento,
    String campo,
  ) async {
    var query = '''
        SELECT count(hlc) as count 
        FROM crdt c  
        JOIN crdt_campos cc ON c.hlc = cc.crdt_hlc 
        WHERE c.rowId = ? AND c.hlc > ? AND cc.nombre = ?;
        ''';

    var dbResult = await _db.query(sql: query, params: [
      evento.rowId,
      evento.hlc.pack(),
      campo,
    ]);

    if (dbResult.isNotEmpty) {
      return dbResult[0]['count'] as int;
    } else {
      return 0;
    }
  }

  @override
  Future<List<EventoSync>> obtenerEventosNoAplicados() async {
    var eventos = <EventoSync>[];

    var query = '''
        SELECT c.dataset,c.rowId,c.hlc,c.version,c.device_id,c.usuario_uid,
          cc.nombre,cc.valor,cc.tipo
        FROM crdt c
        JOIN crdt_campos cc ON c.hlc = cc.crdt_hlc
        WHERE applied = 0
      ''';

    var dbResult = await _db.query(sql: query);

    if (dbResult.isNotEmpty) {
      List<CampoEventoSync> campos = [];
      var eventoHLC = dbResult[0]['hlc'] as String;
      EventoSync? evento;

      for (var dbRow in dbResult) {
        if (eventoHLC != dbRow['hlc'] as String) {
          eventos.add(evento!);

          campos = [];
          eventoHLC = dbRow['hlc'] as String;
        }

        campos.add(
          CampoEventoSync.cargar(
            nombre: dbRow['nombre'] as String,
            valor: dbRow['valor'] as String,
            tipo: dbRow['tipo'] as String,
          ),
        );

        evento = EventoSync(
          dataset: dbRow['dataset'] as String,
          dispositivoID: dbRow['device_id'] as String, //TODO: homologar
          usuarioUID: dbRow['usuario_uid'] as String,
          rowId: dbRow['rowId'] as String,
          version: dbRow['version'] as int,
          campos: campos,
        );

        evento.hlc = HLC.unpack(dbRow['hlc'] as String);
      }

      eventos.add(evento!);
    }

    return eventos;
  }

  @override
  Future<EventoSync?> obtenerEventoPorHLC(String hlc) async {
    EventoSync? evento;

    var query = '''
        SELECT c.dataset,c.rowId,c.hlc,c.version,c.device_id,c.usuario_uid,
          cc.nombre,cc.valor,cc.tipo
        FROM crdt c
        JOIN crdt_campos cc ON c.hlc = cc.crdt_hlc
        WHERE applied = 0 and hlc = ?
      ''';

    var dbResult = await _db.query(sql: query, params: [hlc]);

    if (dbResult.isNotEmpty) {
      List<CampoEventoSync> campos = [];

      for (var dbRow in dbResult) {
        campos.add(
          CampoEventoSync.cargar(
            nombre: dbRow['nombre'] as String,
            valor: dbRow['valor'] as String,
            tipo: dbRow['tipo'] as String,
          ),
        );
      }

      evento = EventoSync(
        dataset: dbResult[0]['dataset'] as String,
        rowId: dbResult[0]['rowId'] as String,
        dispositivoID: dbResult[0]['device_id'] as String,
        usuarioUID: dbResult[0]['usuario_uid'] as String,
        version: dbResult[0]['version'] as int,
        //tipo: TipoEventoSync.values[(dbResult[0]['tipo'] as int)],
        campos: campos,
      );

      evento.hlc = HLC.unpack(hlc);
    }

    return evento;
  }

  @override
  Future<void> agregarEvento(EventoSync evento) async {
    await _db.command(sql: '''
          insert into crdt(hlc,dataset,rowId,device_id,usuario_uid,isLocal,sended,applied,version) 
          values(?,?,?,?,?,?,?,?,?);''', params: [
      evento.hlc.pack(),
      evento.dataset,
      evento.rowId,
      evento.dispositivoID,
      evento.usuarioUID,
      1,
      0,
      0,
      evento.version,
    ]);

    //TODO: agregar index al HLC
    for (var campo in evento.campos) {
      await _db.command(sql: '''
          insert into crdt_campos(crdt_hlc,nombre,valor,tipo) 
          values(?,?,?,?);''', params: [
        evento.hlc.pack(),
        campo.nombre,
        campo.valor,
        campo.tipo,
      ]);
    }
  }

  @override
  Future<void> marcarEventoComoAplicado(EventoSync evento) async {
    await _db.command(
        sql: 'update crdt set applied = 1 where hlc = ?',
        params: [evento.hlc.pack()]);
  }

  @override
  Future<Object?> obtenerColumnaDeDataset({
    required String dataset,
    required String column,
    required String uid,
  }) async {
    var query = 'select $column from $dataset where uid = ?;';

    var dbResult = await _db.query(sql: query, params: [uid]);

    return dbResult.isNotEmpty ? dbResult[0][column] as Object : null;
  }

  @override
  Future<void> agregarEntradaQueue(QueueEntry entrada) async {
    var command =
        'insert into sync_queue(uid, payload, headers) values(?,?,?);';

    await _db.command(sql: command, params: [
      entrada.uid,
      entrada.body,
      jsonEncode(entrada.headers),
    ]);
  }

  @override
  Future<void> borrarEntradaQueue(String uid) async {
    var command = 'delete from sync_queue where uid = ?;';

    await _db.command(sql: command, params: [uid]);
  }

  @override
  Future<List<QueueEntry>> obtenerQueue() async {
    return (await _db.query(
            sql: 'select uid, payload, headers from sync_queue'))
        .map(
          (row) => QueueEntry(
            uid: row['uid'] as String,
            body: row['payload'] as String,
            headers:
                (jsonDecode(row['headers'] as String) as Map<String, dynamic>)
                    .map((k, v) {
              return MapEntry(k.toString(), v.toString());
            }),
          ),
        )
        .toList();
  }

  @override
  Future<void> actualizarFechaDeSincronizacion(int epoch) async {
    var command = 'update syncConfig set ultima_sincronizacion = ?;';

    await _db.command(sql: command, params: [epoch]);
  }
}
