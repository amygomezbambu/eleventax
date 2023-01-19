// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion7 extends Migracion {
  Migracion7() : super() {
    version = 7;
  }

  @override
  Future<void> operacion() async {
    var command = '''
        CREATE TABLE ventas_en_progreso(
          uid TEXT PRIMARY KEY,
          creado_en INTEGER NOT NULL,
          subtotal INTEGER NOT NULL DEFAULT 0000000,
          total_impuestos INTEGER NOT NULL DEFAULT 0000000,
          total INTEGER NOT NULL DEFAULT 0000000          
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE ventas_en_progreso_articulos(
          uid TEXT PRIMARY KEY,
          producto_uid TEXT,
          cantidad REAL,
          precio_venta INTEGER,
          descripcion TEXT,
          agregado_en INTEGER NOT NULL
        ); 
      ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query =
        'select name from sqlite_master where type = ? and name in (?,?);';
    var queryResult = await db.query(sql: query, params: [
      'table',
      'ventas_en_progreso',
      'ventas_en_progreso_articulos'
    ]);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
