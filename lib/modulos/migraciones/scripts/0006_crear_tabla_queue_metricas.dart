// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion6 extends Migracion {
  Migracion6() : super() {
    version = 6;
  }

  @override
  Future<void> operacion() async {
    var command = 'CREATE TABLE metricas_queue('
        'uid TEXT PRIMARY KEY,'
        'ip TEXT,'
        'evento INTEGER,'
        'esPerfil INTEGER NOT NULL CHECK (esPerfil IN (0, 1)) DEFAULT 0,'
        'propiedades TEXT ); ';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult =
        await db.query(sql: query, params: ['table', 'metricas_queue']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
