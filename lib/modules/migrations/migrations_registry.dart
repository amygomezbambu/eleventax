import 'package:eleventa/modules/migrations/migration.dart';
import 'package:eleventa/modules/migrations/scripts/0001_create_items.dart';

List<Migration> getMigrations() {
  var migrations = <Migration>[];

  migrations.add(Migration1());

  //todo: Sort migrations before return them
  return migrations;
}
