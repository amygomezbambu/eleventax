// ignore_for_file: file_names
import 'package:eleventa/modules/migrations/migration.dart';
import 'package:eleventa/utils/utils.dart';

class Migration2 extends Migration {
  Migration2() : super() {
    version = 2;
  }

  @override
  Future<void> operation() async {
    var command = 'insert into items(uid,description,sku,price) '
        'values(?, "Coke 20oz", "1", 10.5)';

    await db.command(sql: command, params: [Utils.uid.generate()]);

    command = 'insert into items(uid,description,sku,price) '
        'values(?, "Starbucks Coffee", "2", 10.0)';

    await db.command(sql: command, params: [Utils.uid.generate()]);

    command = 'insert into items(uid,description,sku,price) '
        'values(?, "Tuna Sandwich", "3", 12.00)';

    await db.command(sql: command, params: [Utils.uid.generate()]);
  }

  @override
  Future<bool> validate() async {
    return true;
  }
}
