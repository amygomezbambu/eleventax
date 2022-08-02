import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/common/infra/sqlite_adapter.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:meta/meta.dart';

class Repository implements IRepository {
  @protected
  late IDatabaseAdapter db;

  Repository() {
    db = SQLiteAdapter();
  }

  @override
  Future<void> transaction() async {
    await db.transaction();
  }

  @override
  Future<void> commit() async {
    await db.commit();
  }

  @override
  Future<void> rollback() async {
    await db.rollback();
  }
}
