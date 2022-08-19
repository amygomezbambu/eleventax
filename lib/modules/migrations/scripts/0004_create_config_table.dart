// ignore_for_file: file_names
import 'package:eleventa/modules/migrations/migration.dart';

class Migration4 extends Migration {
  Migration4() : super() {
    version = 4;
  }

  @override
  Future<void> operation() async {
    var command = 'CREATE TABLE config('
        'uid text primary key,' //unique
        'module text null,'
        'value text null'
        ');';

    await db.command(sql: command);
  }

  @override
  Future<bool> validate() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult = await db.query(sql: query, params: ['table', 'config']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
