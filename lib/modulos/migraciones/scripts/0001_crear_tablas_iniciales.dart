// ignore_for_file: file_names
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion1 extends Migracion {
  Migracion1() : super() {
    version = 1;
  }

  @override
  Future<void> operacion() async {
    var command = 'CREATE TABLE ventas('
        'uid text primary key,' //unique
        'nombre text null,'
        'total decimal(10,4) null,'
        'status integer null,'
        'metodo_de_pago integer null,'
        'fecha_de_pago integer null'
        ');';

    await db.command(sql: command);

    command = '''
        CREATE TABLE articulos_de_venta(
          venta_uid TEXT NOT NULL,
          producto_uid TEXT NOT NULL, 
          cantidad DECIMAL NOT NULL,
          PRIMARY KEY (venta_uid, producto_uid)          
        );
      ''';

    await db.command(sql: command);

    command = 'CREATE TABLE productos('
        'uid TEXT PRIMARY KEY,'
        'descripcion TEXT NULL,'
        'sku TEXT,'
        'precio DECIMAL NULL'
        ');';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult = await db.query(sql: query, params: ['table', 'ventas']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
