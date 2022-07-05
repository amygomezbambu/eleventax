import 'package:eleventa/dependencies.dart';

class Migration {
  var db = Dependencies.infra.database();
  //var logger = Container.infra.logger();

  late var version = 0;

  Future<void> execute() async {
    //logger.info('executing migration # $version');

    try {
      await db.transaction();

      await operation();

      if (await validate()) {
        await db.commit();
      } else {
        await db.rollback();

        throw Exception('Migración $version no se ejecutó correctamente');
      }
    } catch (error) {
      await db.rollback();

      // var err = InfrastructureError(error.toString(), stackTrace.toString());

      //logger.error(err);
      // throw err;

      rethrow;
    }
  }

  Future<void> operation() async {}

  Future<bool> validate() async {
    //placeholder, sera sobreescrito por el metodo heredado
    return true;
  }
}
