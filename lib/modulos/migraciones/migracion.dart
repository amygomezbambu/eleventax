import 'package:eleventa/dependencias.dart';

class Migracion {
  var db = Dependencias.infra.database();
  //var logger = Container.infra.logger();

  late var version = 0;

  Future<void> exec() async {
    //logger.info('executing migration # $version');

    try {
      await db.transaction();

      await operacion();

      if (await validar()) {
        await db.commit();
      } else {
        await db.rollback();

        throw Exception('Migración $version no se ejecutó correctamente');
      }
    } catch (error) {
      await db.rollback();

      rethrow;
    }
  }

  Future<void> operacion() async {}

  Future<bool> validar() async {
    //placeholder, sera sobreescrito por el metodo heredado
    return true;
  }
}
