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
    var command = 'insert into impuestos(uid,nombre,porcentaje) '
        'values(?, "IVA 8%", 8000000)';

    await db.command(sql: command, params: [UID().toString()]);

    command = 'insert into impuestos(uid,nombre,porcentaje) '
        'values(?, "IVA 16%", 16000000)';

    await db.command(sql: command, params: [UID().toString()]);

    command = 'insert into impuestos(uid,nombre,porcentaje) '
        'values(?, "IVA 0%", 0)';

    await db.command(sql: command, params: [UID().toString()]);

    /*Creacion de Unidad de Medida*/

    command = 'insert into unidades_medida(uid,nombre,abreviacion) '
        'values(?, "Pieza", "Pza")';

    await db.command(sql: command, params: [UID().toString()]);

    command = 'insert into unidades_medida(uid,nombre,abreviacion) '
        'values(?, "Kilogramo / Gramo", "Kg/gr")';

    await db.command(sql: command, params: [UID().toString()]);

    command = 'insert into unidades_medida(uid,nombre,abreviacion) '
        'values(?, "Metro / Centimetro", "m/cm")';

    await db.command(sql: command, params: [UID().toString()]);
  }

  @override
  Future<bool> validar() async {
    return true;
  }
}
