import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/telemetry.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/sales/app/interface/local_config_adapter.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';

class _DependenciesModule {
  final Map<String, Object Function()> _deps;

  _DependenciesModule(this._deps);

  T obtainDependency<T>() {
    if (_deps.containsKey((T).toString())) {
      var concrete = _deps[(T).toString()]!();

      return concrete as T;
    } else {
      throw AssertionError(
          'No se encontró un registro para esta dependencia: ${T.toString()}');
    }
  }
}

class InfraStructureDependencies extends _DependenciesModule {
  InfraStructureDependencies(Map<String, Object Function()> deps) : super(deps);

  IDatabaseAdapter database() {
    return obtainDependency<IDatabaseAdapter>();
  }

  ILogger logger() {
    return obtainDependency<ILogger>();
  }

  ISync syncAdapter() {
    return obtainDependency<ISync>();
  }

  ITelemetryAdapter telemetryAdapter() {
    return obtainDependency<ITelemetryAdapter>();
  }
}

class SalesDependencies extends _DependenciesModule {
  SalesDependencies(Map<String, Object Function()> deps) : super(deps);

  ISaleRepository saleRepository() {
    return obtainDependency<ISaleRepository>();
  }

  IItemRepository itemRepository() {
    return obtainDependency<IItemRepository>();
  }

  ISaleLocalConfigAdapter saleLocalConfigAdapter() {
    return obtainDependency<ISaleLocalConfigAdapter>();
  }
}

class Dependencies {
  static final _deps = <String, Object Function()>{};

  static final InfraStructureDependencies infra =
      InfraStructureDependencies(_deps);
  static final SalesDependencies sales = SalesDependencies(_deps);

  static register(String abstractName, Object Function() builder) {
    _deps.putIfAbsent(abstractName, () => builder);
  }
}
