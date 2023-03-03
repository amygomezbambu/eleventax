// ignore_for_file: file_names
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion2 extends Migracion {
  Migracion2() : super() {
    version = 2;
  }

  @override
  Future<void> operacion() async {
    /*Creacion de impuestos iniciales*/
    var command = 'insert into impuestos(uid,nombre,porcentaje,orden) '
        'values(?, ?, 8000000,2)';

    await db.command(sql: command, params: [UID().toString(), 'IVA 8%']);

    command = 'insert into impuestos(uid,nombre,porcentaje,orden) '
        'values(?, ?, 16000000,2)';

    await db.command(sql: command, params: [UID().toString(), 'IVA 16%']);

    command = 'insert into impuestos(uid,nombre,porcentaje,orden) '
        'values(?, ?, 0,2)';

    await db.command(sql: command, params: [UID().toString(), 'IVA 0%']);

    command = 'insert into impuestos(uid,nombre,porcentaje,orden) '
        'values(?, ?, 3000000, 1)';

    await db.command(sql: command, params: [UID().toString(), 'IEPS 3%']);

    /* Categorias Iniciales */
    command = 'INSERT INTO categorias (uid, nombre) VALUES (?, ?)';
    await db.command(sql: command, params: [UID().toString(), 'Refrescos']);
    command = 'INSERT INTO categorias (uid, nombre) VALUES (?, ?)';
    await db.command(sql: command, params: [UID().toString(), 'Verduras']);
    command = 'INSERT INTO categorias (uid, nombre) VALUES (?, ?)';
    await db.command(sql: command, params: [UID().toString(), 'Frutas']);

    /*Creacion de Unidad de Medida*/

    command = 'insert into unidades_medida(uid,nombre,abreviacion) '
        'values(?, ?, ?)';

    await db
        .command(sql: command, params: [UID().toString(), 'Pieza', 'pz']); //

    command = 'insert into unidades_medida(uid,nombre,abreviacion) '
        'values(?, ?, ?)';

    await db
        .command(sql: command, params: [UID().toString(), 'Kilogramo', 'kg']);

    command = 'insert into unidades_medida(uid,nombre,abreviacion) '
        'values(?, ?, ?)';

    await db.command(
        sql: command, params: [UID().toString(), 'Metro / Centimetro', 'm/cm']);
  }

  @override
  Future<bool> validar() async {
    return true;
  }
}