import 'package:eleventa/modules/migrations/migration_repository.dart';
import 'package:eleventa/modules/migrations/migrations_registry.dart'
    as migrations_registry;

class MigrateDB {
  MigrateDB();

  Future<void> exec() async {
    Object? error;
    var version = 0;

    await MigrationRepository.createTableMigrationsIfDontExists();

    version = await MigrationRepository.getMigrationVersion();

    var migrations = migrations_registry.getMigrations();

    for (var migration in migrations) {
      try {
        if (migration.version > version) {
          await migration.execute();
          version = migration.version;
        }
      } catch (e) {
        error = e;
        break;
      }
    }

    await MigrationRepository.saveMigrationVersion(version);

    if (error != null) {
      //si una migración falló debemos cerrar el programa ya que la db
      //quedo en un estado invalido, pero debemos hacer algo mas? , debemos
      //dar un tiempo de espera antes de cerrar? o debemos dejarle la
      //responsabilidad a la UI para que avise primero al usuario?

      //por lo pronto solo hacemos rethrow
      throw error;
    }
  }
}
