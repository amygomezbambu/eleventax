import 'package:eleventa/modules/migrations/migration.dart';

class Migration1 extends Migration {
  Migration1() : super() {
    version = 1;
  }

  @override
  Future<void> operation() async {
    var command = 'create table sales('
        'id integer primary key autoincrement,'
        'uid varchar(50) ,' //unique
        'name varchar(100) null,'
        'total decimal(10,4) null,'
        'status integer null,'
        'paymentMethod integer null,'
        'paymentTimeStamp integer null'
        ');';

    await db.command(sql: command);

    command = 'create table items('
        'id integer primary key autoincrement,'
        'uid varchar(50) unique,'
        'description varchar(255) null,'
        'sku varchar(50) null,'
        'price decimal(10,4) null'
        ');';

    await db.command(sql: command);

    command = 'create table crdt('
        'hlc varchar(40),'
        'dataset varchar(100),'
        'rowId varchar(50),'
        'column varchar(50),'
        'value text,'
        'type char,' //S: string, N: number, B: Bool
        'isLocal integer,'
        'sended integer,'
        'applied integer'
        ');';

    await db.command(sql: command);

    command = 'create table syncConfig(hlc varchar(40));';

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
