// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion7 extends Migracion {
  Migracion7() : super() {
    version = 7;
  }

  @override
  Future<void> operacion() async {
    const command = '''
        CREATE TABLE ventas_en_progreso(
          uid TEXT PRIMARY KEY,
          creado_en INTEGER NOT NULL
        ); 
      ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult =
        await db.query(sql: query, params: ['table', 'ventas_en_progreso']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
