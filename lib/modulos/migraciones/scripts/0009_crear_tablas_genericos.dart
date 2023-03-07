// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion9 extends Migracion {
  Migracion9() : super() {
    version = 9;
  }

  @override
  Future<void> operacion() async {
    var command = '''
        CREATE TABLE ventas_productos_genericos(
          uid TEXT PRIMARY KEY,
          precio_venta INTEGER,
          nombre TEXT
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE ventas_genericos_en_progreso(
          uid TEXT PRIMARY KEY,
          precio_venta INTEGER,
          nombre TEXT
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE ventas_genericos_en_progreso_impuestos(
          producto_generico_uid TEXT,
          impuesto_uid TEXT
        ); 
      ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query =
        'select name from sqlite_master where type = ? and name in (?,?,?);';
    var queryResult = await db.query(sql: query, params: [
      'table',
      'ventas_productos_genericos',
      'ventas_genericos_en_progreso',
      'ventas_genericos_en_progreso_impuestos',
    ]);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
