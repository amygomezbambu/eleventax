import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';
import 'package:eleventa/modules/sales/sales_config.dart';

abstract class ISaleRepository extends IRepository<Sale> {
  Future<void> addSaleItem(SaleItem item);
  Future<void> updateChargeData(Sale sale);
  Future<void> saveSharedConfig(SalesSharedConfig config);
  Future<SalesSharedConfig> getSharedConfig();
}
