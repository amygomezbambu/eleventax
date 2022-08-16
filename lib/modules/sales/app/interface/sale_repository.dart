import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';

import '../../sales_config.dart';

abstract class ISaleRepository extends IRepository {
  Future<void> add(Sale sale);
  Future<void> addSaleItem(SaleItem item);
  Future<Sale?> get(String uid);
  Future<void> update(Sale sale);
  Future<void> updateChargeData(Sale sale);
  List<Sale> getAll();

  Future<void> saveLocalConfig(SalesLocalConfig config);
  Future<void> saveSharedConfig(SalesSharedConfig config);
  Future<SalesSharedConfig> getSharedConfig();
}
