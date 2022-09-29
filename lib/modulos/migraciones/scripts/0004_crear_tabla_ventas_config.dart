// ignore_for_file: file_names
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion4 extends Migracion {
  Migracion4() : super() {
    version = 4;
  }

  @override
  Future<void> operacion() async {
    var command = 'CREATE TABLE config_ventas('
        'uid text primary key,' //unique
        'permitirProductoComun bool null,'
        'permitirCostoZero bool null'
        ');';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult =
        await db.query(sql: query, params: ['table', 'config_ventas']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
