// ignore_for_file: file_names
import 'package:eleventa/modules/migrations/migration.dart';

class Migration1 extends Migration {
  Migration1() : super() {
    version = 1;
  }

  @override
  Future<void> operation() async {
    var command = 'CREATE TABLE sales('
        'uid text primary key,' //unique
        'name text null,'
        'total decimal(10,4) null,'
        'status integer null,'
        'paymentMethod integer null,'
        'paymentTimeStamp integer null'
        ');';

    await db.command(sql: command);

    command = '''
        CREATE TABLE sale_items(
          sales_uid TEXT NOT NULL,
          items_uid TEXT NOT NULL, 
          quantity DECIMAL NOT NULL,
          PRIMARY KEY (sales_uid, items_uid)          
        );
      ''';

    await db.command(sql: command);

    command = 'CREATE TABLE items('
        'uid TEXT PRIMARY KEY,'
        'description TEXT NULL,'
        'sku TEXT,'
        'price DECIMAL NULL'
        ');';

    await db.command(sql: command);
  }

  @override
  Future<bool> validate() async {
    const query = 'select name from sqlite_master where type = ? and name = ?;';
    var queryResult = await db.query(sql: query, params: ['table', 'sales']);

    if (queryResult.isNotEmpty) {
      return true;
    }

    return false;
  }
}
