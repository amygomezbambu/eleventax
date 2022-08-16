import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/charge_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/get_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/update_config.dart';
import './sales_config.dart';
import 'app/usecase/get_config.dart';

class SalesModule {
  static final config = SalesConfig();

  static AddSaleItem addSaleItem() {
    return AddSaleItem(Dependencies.sales.saleRepository());
  }

  static CreateSale createSale() {
    return CreateSale();
  }

  static ChargeSale chargeSale() {
    return ChargeSale(Dependencies.sales.saleRepository());
  }

  static GetSale getSale() {
    return GetSale(Dependencies.sales.saleRepository());
  }

  static GetConfig getConfig() {
    return GetConfig(Dependencies.sales.saleRepository());
  }

  static UpdateConfig updateConfig() {
    return UpdateConfig(Dependencies.sales.saleRepository());
  }
}
