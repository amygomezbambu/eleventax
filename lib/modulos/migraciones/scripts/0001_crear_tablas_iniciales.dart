// ignore_for_file: file_names
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion1 extends Migracion {
  Migracion1() : super() {
    version = 1;
  }

  @override
  Future<void> operacion() async {
    var command = '''
        CREATE TABLE unidades_medida(
        uid TEXT PRIMARY KEY,
        nombre TEXT NULL,
        abreviacion TEXT NULL,
        borrado INTEGER NOT NULL CHECK (borrado IN (0, 1)) DEFAULT 0
        ) ''';

    await db.command(sql: command);

    command = '''
         CREATE TABLE categorias(
        uid TEXT PRIMARY KEY,
        nombre TEXT NULL,
        borrado INTEGER NOT NULL CHECK (borrado IN (0, 1)) DEFAULT 0
        ) ''';

    await db.command(sql: command);

    command = ''' CREATE TABLE impuestos(
        uid TEXT PRIMARY KEY,
        nombre TEXT NULL,
        porcentaje INTEGER NULL,
        orden INTEGER NULL,
        borrado INTEGER NOT NULL CHECK (borrado IN (0, 1)) DEFAULT 0,
        activo INTEGER NOT NULL CHECK (activo IN (0, 1)) DEFAULT 1
        ); ''';

    await db.command(sql: command);

    //TODO: no necesitamos los datos en el producto, solo que apunte a la ultima version
    // y de ahi obtenemos los datos
    command = '''
        CREATE TABLE productos(
          uid TEXT PRIMARY KEY,
          codigo TEXT NULL,
          nombre TEXT NULL,
          precio_compra INTEGER NULL,
          precio_venta INTEGER NULL DEFAULT 0,
          categoria_uid TEXT NULL,
          unidad_medida_uid TEXT NULL,
          url_imagen TEXT NULL,
          se_vende_por INTEGER NULL,       
          borrado BOOLEAN NOT NULL CHECK (borrado IN (0, 1)) DEFAULT 0,
          bloqueado BOOLEAN NOT NULL CHECK (borrado IN (0, 1)) DEFAULT 0,
          preguntar_precio BOOLEAN NOT NULL CHECK (preguntar_precio IN (0,1)) DEFAULT 0,
          version_actual_uid TEXT
        );
        ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE productos_versiones(
          uid TEXT PRIMARY KEY, -- Este es el UID de la version, pero se llama UID ya que asi lo requiere el sync
          producto_uid TEXT NULL, 
          codigo TEXT NULL,
          nombre TEXT NULL,
          precio_compra INTEGER NULL,
          precio_venta INTEGER NULL,
          categoria_nombre TEXT NULL,
          unidad_medida_nombre TEXT NULL,
          unidad_medida_abreviacion TEXT NULL,
          url_imagen TEXT NULL,
          se_vende_por INTEGER NULL,
          preguntar_precio BOOLEAN NOT NULL CHECK (preguntar_precio IN (0,1)) DEFAULT 0,
          guardado_en INTEGER
        );
        ''';

    await db.command(sql: command);

    command =
        'CREATE INDEX IX_productos_categoria_uid ON productos (categoria_uid);';
    await db.command(sql: command);
    command =
        'CREATE INDEX IX_productos_unidad_medida_uid ON productos (unidad_medida_uid);';
    await db.command(sql: command);

    command = '''
        CREATE TABLE productos_impuestos(
        uid TEXT PRIMARY KEY,
        producto_uid TEXT,
        impuesto_uid TEXT,
        borrado INTEGER NOT NULL CHECK (borrado IN (0, 1)) DEFAULT 0
        ) 
      ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query = 'SELECT name FROM sqlite_master WHERE type = ? AND name = ?;';
    var queryResult =
        await db.query(sql: query, params: ['table', 'productos']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
