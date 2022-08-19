import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:meta/meta.dart';

class Repository implements IRepository {
  @protected
  late IDatabaseAdapter db;
  @protected
  late ISync sync;

  Repository(ISync? sync, IDatabaseAdapter? db) {
    if (db != null) {
      this.db = db;
    } else {
      this.db = Dependencies.infra.database();
    }

    if (sync != null) {
      this.sync = sync;
    } else {
      this.sync = Dependencies.infra.sync();
    }
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
