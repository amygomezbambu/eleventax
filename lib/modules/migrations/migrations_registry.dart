import 'package:eleventa/modules/migrations/migration.dart';
import 'package:eleventa/modules/migrations/scripts/0001_create_items.dart';
import 'package:eleventa/modules/migrations/scripts/0002_add_dummy_products.dart';

List<Migration> getMigrations() {
  var migrations = <Migration>[];

  migrations.add(Migration1());
  migrations.add(Migration2());

  //todo: Sort migrations before return them
  return migrations;
}
