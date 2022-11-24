// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion5 extends Migracion {
  Migracion5() : super() {
    version = 5;
  }

  @override
  Future<void> operacion() async {
    var command = 'CREATE TABLE notificaciones('
        'uid TEXT PRIMARY KEY,'
        'tipo INTEGER NULL,'
        'timestamp INTEGER NULL,'
        'mensaje TEXT NULL'
        ') ';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult =
        await db.query(sql: query, params: ['table', 'notificaciones']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
