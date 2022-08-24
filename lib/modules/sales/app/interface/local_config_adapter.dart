import 'package:eleventa/modules/sales/sales_config.dart';

abstract class ISaleLocalConfigAdapter {
  Future<void> save(SalesLocalConfig config);
  Future<SalesLocalConfig> read();
}
