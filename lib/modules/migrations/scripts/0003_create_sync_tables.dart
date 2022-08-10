import 'package:eleventa/modules/migrations/migration.dart';

class Migration3 extends Migration {
  Migration3() : super() {
    version = 3;
  }

  @override
  Future<void> operation() async {
    var command = 'create table crdt('
        'hlc varchar(40),'
        'dataset varchar(100),'
        'rowId varchar(50),'
        'column varchar(50),'
        'value text,'
        'type char,' //S: string, N: number, B: Bool
        'isLocal integer,'
        'sended integer,'
        'applied integer,'
        'version integer'
        ');';

    await db.command(sql: command);

    command = 'create table syncConfig(hlc varchar(40), merkle text);';

    await db.command(sql: command);

    command = 'insert into syncConfig(hlc,merkle) values(?,?);';

    await db.command(sql: command, params: ['', '']);
  }

  @override
  Future<bool> validate() async {
    return true;
  }
}
