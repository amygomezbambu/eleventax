import 'package:eleventa/container.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';

class SalesModule {
  static AddSaleItem addSaleItem() {
    return AddSaleItem(Dependencies.sales.saleRepository());
  }

  static CreateSale createSale() {
    return CreateSale();
  }
}
