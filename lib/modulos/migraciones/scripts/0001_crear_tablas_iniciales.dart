// ignore_for_file: file_names
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion1 extends Migracion {
  Migracion1() : super() {
    version = 1;
  }

  @override
  Future<void> operacion() async {
    var command = 'CREATE TABLE unidades_medida('
        'uid TEXT PRIMARY KEY,'
        'nombre TEXT NULL,'
        'abreviacion TEXT NULL'
        ') ';

    await db.command(sql: command);

    command = 'CREATE TABLE productos_categorias('
        'uid TEXT PRIMARY KEY,'
        'nombre TEXT NULL'
        ') ';

    await db.command(sql: command);

    command = 'CREATE TABLE impuestos('
        'uid TEXT PRIMARY KEY,'
        'nombre TEXT NULL,'
        'porcentaje INTEGER NULL'
        ') ';

    await db.command(sql: command);

    command = 'CREATE TABLE productos('
        'uid TEXT PRIMARY KEY,'
        'codigo TEXT NULL,'
        'nombre TEXT NULL,'
        'precio_compra INTEGER NULL,'
        'precio_venta INTEGER NULL,'
        'categoria_uid TEXT NULL,'
        'unidad_medida_uid TEXT NULL,'
        'url_imagen TEXT NULL,'
        'se_vende_por INTEGER NULL'
        ') ';

    await db.command(sql: command);

    command =
        'CREATE INDEX IX_productos_categoria_uid ON productos (categoria_uid);';
    await db.command(sql: command);
    command =
        'CREATE INDEX IX_productos_unidad_medida_uid ON productos (unidad_medida_uid);';
    await db.command(sql: command);

    command = 'CREATE TABLE productos_impuestos('
        'uid TEXT PRIMARY KEY,'
        'producto_uid TEXT,'
        'impuesto_uid TEXT'
        ') ';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult =
        await db.query(sql: query, params: ['table', 'productos']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
