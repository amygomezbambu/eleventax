// ignore_for_file: file_names
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion4 extends Migracion {
  Migracion4() : super() {
    version = 4;
  }

  @override
  Future<void> operacion() async {
    var command = 'CREATE TABLE config_ventas('
        'uid text primary key,'
        'permitirProductoComun INTEGER null,'
        'permitirCostoZero INTEGER null'
        ') STRICT;';

    await db.command(sql: command);

    command = '''
        CREATE TABLE config_productos(
        uid TEXT PRIMARY KEY, 
        permitirPrecioCompraCero INTEGER NOT NULL CHECK (permitirPrecioCompraCero IN (0, 1)) DEFAULT 0       
        ) STRICT;
        ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query =
        'SELECT name FROM sqlite_master WHERE type = ? AND name in (?,?);';
    var queryResult = await db.query(
        sql: query, params: ['table', 'config_ventas', 'config_productos']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
