import 'package:eleventa/modules/common/infra/local_config.dart';
import 'package:eleventa/modules/sales/app/interface/local_config_adapter.dart';
import 'package:eleventa/modules/sales/sales_config.dart';

class SaleLocalConfigAdapter extends LocalConfig
    implements ISaleLocalConfigAdapter {
  @override
  Future<SalesLocalConfig> read() async {
    var localConfig = SalesLocalConfig();

    localConfig.allowDiscounts =
        (await readValue<bool>('allowDiscounts')) ?? localConfig.allowDiscounts;

    return localConfig;
  }

  @override
  Future<void> save(SalesLocalConfig config) async {
    var values = config.toMap();

    for (var key in values.keys) {
      await saveValue(key, values[key]!);
    }
  }
}
