import 'package:eleventa/modules/migrations/migration.dart';
import 'package:uuid/uuid.dart';

class Migration2 extends Migration {
  Migration2() : super() {
    version = 2;
  }

  @override
  Future<void> operation() async {
    var command = 'insert into items(uid,description,sku,price) '
        'values(?, "coca cola", "0001", 10.5)';

    await db.command(sql: command, params: [const Uuid().v4()]);

    command = 'insert into items(uid,description,sku,price) '
        'values(?, "sabritas 250 grs", "0002", 10.0)';

    await db.command(sql: command, params: [const Uuid().v4()]);

    command = 'insert into items(uid,description,sku,price) '
        'values(?, "atun tuny 200 grs", "0003", 12.00)';

    await db.command(sql: command, params: [const Uuid().v4()]);
  }

  @override
  Future<bool> validate() async {
    return true;
  }
}
