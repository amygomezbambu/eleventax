import 'package:eleventa/dependencies.dart';

class MigrationRepository {
  static final _db = Dependencies.infra.database();
  //static final _logger = Container.infra.logger();

  static Future<void> createTableMigrationsIfDontExists() async {
    var query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult =
        await _db.query(sql: query, params: ['table', 'migrations']);

    if (queryResult.isEmpty) {
      var command = 'create table migrations( version integer not null);';
      await _db.command(sql: command);

      //_logger.info('table migrations created');

      //version 0 indica que aun no se ejecuta ninguna migracion
      await saveMigrationVersion(0);
    }
  }

  static Future<void> saveMigrationVersion(int version) async {
    //_logger.info('updating db version to: ' + version.toString());

    if (version == 0) {
      await _db.command(
        sql: 'insert into migrations(version) values(?);',
        params: [version],
      );
    } else {
      await _db.command(
        sql: 'update migrations set version = ?;',
        params: [version],
      );
    }
  }

  static Future<int> getMigrationVersion() async {
    var queryResult = await _db.query(sql: 'select version from migrations;');

    if (queryResult.isEmpty) {
      return 0;
    }

    return queryResult[0]['version'] as int;
  }
}
