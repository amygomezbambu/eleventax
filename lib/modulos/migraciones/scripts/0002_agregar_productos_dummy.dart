// ignore_for_file: file_names
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion2 extends Migracion {
  Migracion2() : super() {
    version = 2;
  }

  @override
  Future<void> operacion() async {
    var command = 'insert into productos(uid,descripcion,sku,precio) '
        'values(?, "Coke 20oz", "1", 10.33)';

    await db.command(sql: command, params: [UID().toString()]);

    command = 'insert into productos(uid,descripcion,sku,precio) '
        'values(?, "Starbucks Coffee", "2", 10.33)';

    await db.command(sql: command, params: [UID().toString()]);

    command = 'insert into productos(uid,descripcion,sku,precio) '
        'values(?, "Tuna Sandwich", "3", 12.33)';

    await db.command(sql: command, params: [UID().toString()]);
  }

  @override
  Future<bool> validar() async {
    return true;
  }
}
