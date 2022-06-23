import 'package:eleventa/container.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/charge_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/get_sale.dart';

class SalesModule {
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
}
