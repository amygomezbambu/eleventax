// ignore_for_file: file_names

import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/migraciones/migracion.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';

class Migracion7 extends Migracion {
  Migracion7() : super() {
    version = 7;
  }

  Future<void> _insertarFormaDePago(
      String nombre, int orden, TipoFormaDePago tipo) async {
    var command = '''
      INSERT INTO formas_de_pago (uid,nombre,orden,tipo) VALUES(?,?,?,?)
    ''';

    await db.command(
        sql: command,
        params: [UID().toString(), nombre, orden, tipo.abreviacion]);
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
          venta_uid TEXT,
          producto_uid TEXT,
          cantidad REAL,
          precio_venta INTEGER,
          descripcion TEXT,
          agregado_en INTEGER NOT NULL
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE ventas(
          uid TEXT PRIMARY KEY,
          folio TEXT,
          creado_en INTEGER,
          cobrado_en INTEGER,
          subtotal INTEGER,
          estado INTEGER,
          total_impuestos INTEGER,
          total INTEGER         
        ); 
      ''';

    await db.command(sql: command);

    command = '''
       CREATE UNIQUE INDEX idx_ventas_folio ON ventas(folio); 
      ''';

    await db.command(sql: command);

    command = '''
       CREATE INDEX idx_ventas_cobrado_en ON ventas(cobrado_en); 
      ''';

    await db.command(sql: command);

    //TODO: actualizar prueba para verificar que solo obtenga los articulos de la venta_uid

    command = '''
        CREATE TABLE ventas_articulos(
          uid TEXT PRIMARY KEY,
          version_producto_uid TEXT, 
          venta_uid TEXT,
          cantidad REAL,
          precio_venta INTEGER,
          subtotal INTEGER,
          descripcion TEXT,
          agregado_en INTEGER
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE ventas_articulos_impuestos(
          uid TEXT PRIMARY KEY,
          articulo_uid TEXT,
          nombre_impuesto TEXT,
          porcentaje_impuesto TEXT,
          base_impuesto INTEGER,
          monto INTEGER
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE ventas_pagos(
          uid TEXT PRIMARY KEY, 
          venta_uid TEXT,
          forma_de_pago_uid TEXT,
          monto INTEGER,
          pago_con INTEGER,
          referencia TEXT
        ); 
      ''';

    await db.command(sql: command);

    command = '''
        CREATE TABLE formas_de_pago(
          uid TEXT PRIMARY KEY,
          nombre TEXT,
          orden INTEGER,
          borrado INTEGER DEFAULT 0,
          activo INTEGER DEFAULT 1,
          tipo TEXT
        ); 
      ''';

    await db.command(sql: command);

    await _insertarFormaDePago('Efectivo', 1, TipoFormaDePago.efectivo);
    await _insertarFormaDePago(
        'Transferencia electrónica', 2, TipoFormaDePago.generico);
    await _insertarFormaDePago(
        'Tarjeta de crédito/débito', 3, TipoFormaDePago.generico);

    command = '''
        CREATE TABLE ventas_impuestos(
          uid TEXT PRIMARY KEY,
          venta_uid TEXT,
          nombre_impuesto TEXT,
          porcentaje_impuesto TEXT,
          base_impuesto INTEGER,
          monto INTEGER
        ); 
      ''';

    await db.command(sql: command);
  }

  @override
  Future<bool> validar() async {
    const query =
        'select name from sqlite_master where type = ? and name in (?,?,?,?,?,?,?,?);';
    var queryResult = await db.query(sql: query, params: [
      'table',
      'ventas_en_progreso',
      'ventas_en_progreso_articulos',
      'ventas',
      'ventas_articulos',
      'ventas_pagos',
      'formas_de_pago',
      'ventas_impuestos',
      'ventas_articulos_impuestos'
    ]);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
