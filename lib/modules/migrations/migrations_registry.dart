import 'package:eleventa/modules/migrations/migration.dart';
import 'package:eleventa/modules/migrations/scripts/0001_create_items.dart';
import 'package:eleventa/modules/migrations/scripts/0002_add_dummy_products.dart';
import 'package:eleventa/modules/migrations/scripts/0003_create_sync_tables.dart';
import 'package:eleventa/modules/migrations/scripts/0004_create_sales_config_table.dart';

List<Migration> getMigrations() {
  var migrations = <Migration>[];

  migrations.add(Migration1());
  migrations.add(Migration2());
  migrations.add(Migration3());
  migrations.add(Migration4());

  //todo: Sort migrations before return them
  return migrations;
}
