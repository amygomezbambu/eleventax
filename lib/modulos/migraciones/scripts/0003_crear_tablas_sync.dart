// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion3 extends Migracion {
  Migracion3() : super() {
    version = 3;
  }

  @override
  Future<void> operacion() async {
    var command = 'create table crdt('
        'hlc varchar(40) primary key,'
        'device_id TEXT,'
        'usuario_uid TEXT,'
        'dataset varchar(100),'
        'rowId varchar(50),'
        'isLocal integer,'
        'sended integer,'
        'applied integer,'
        'version integer'
        ');';

    await db.command(sql: command);

    command = 'create table crdt_campos('
        'crdt_hlc TEXT,'
        'nombre TEXT,'
        'valor TEXT,'
        'tipo char'
        ');';

    await db.command(sql: command);

    command =
        'create table syncConfig(hlc text, merkle text, ultima_sincronizacion integer);';

    await db.command(sql: command);

    command =
        'insert into syncConfig(hlc,merkle,ultima_sincronizacion) values(?,?,?);';

    await db.command(sql: command, params: ['', '', 0]);

    command = 'CREATE TABLE sync_duplicados('
        'uid TEXT PRIMARY KEY,'
        'sucedio_primero TEXT NOT NULL,'
        'sucedio_despues TEXT NOT NULL,'
        'dataset TEXT NOT NULL,'
        'column TEXT NOT NULL'
        ');';

    await db.command(sql: command);

    command = ''' 
      CREATE TABLE sync_queue(
        uid TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        headers TEXT NOT NULL
      );
    ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query =
        'SELECT name FROM sqlite_master WHERE type = ? AND name in (?,?,?,?,?);';
    var queryResult = await db.query(sql: query, params: [
      'table',
      'crdt',
      'crdt_campos',
      'syncConfig',
      'sync_duplicados',
      'sync_queue',
    ]);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
