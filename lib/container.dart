import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/infra/sqlite_adapter.dart';

class InfraStructureDependencies {
  IDatabaseAdapter database() {
    return SQLiteAdapter();
  }
}

class Container {
  static final InfraStructureDependencies infra = InfraStructureDependencies();
}
