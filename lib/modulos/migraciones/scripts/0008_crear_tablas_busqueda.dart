// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion8 extends Migracion {
  Migracion8() : super() {
    version = 8;
  }

  @override
  Future<void> operacion() async {
    var command = '''
        CREATE VIRTUAL TABLE productos_busqueda
        USING fts5(nombre, codigo, categoria_nombre, precio_venta UNINDEXED, uid UNINDEXED);
      ''';

    await db.command(sql: command);

    command = '''
      CREATE TRIGGER productos_ai AFTER INSERT ON productos
      BEGIN
        INSERT INTO productos_busqueda(rowid, uid)
        VALUES (new.rowid, new.uid);
      END;''';

    command = '''
      CREATE TRIGGER productos_au AFTER UPDATE ON productos
      BEGIN
        DELETE FROM productos_busqueda WHERE rowid = new.rowid;
        INSERT INTO productos_busqueda(codigo, nombre, categoria_nombre, precio_venta, uid, rowid)
        VALUES (
          new.codigo, 
          new.nombre,
          (SELECT nombre FROM categorias WHERE uid = new.categoria_uid), 
          new.precio_venta, 
          new.uid, 
          new.rowid);
      END;''';

    await db.command(sql: command);

    command = '''
      CREATE TRIGGER categorias_au AFTER UPDATE ON categorias
      BEGIN
        UPDATE productos_busqueda SET categoria_nombre = new.nombre WHERE categoria_nombre = old.nombre;        
      END;''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    // TODO: Realizar esta validacion
    return true;
  }
}
