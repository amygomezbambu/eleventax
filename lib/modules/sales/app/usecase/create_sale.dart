import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class CreateSaleRequest {
  int cashierId = 0;
  int deviceId = 0;
}

class CreateSale {
  final request = CreateSaleRequest();

  String exec() {
    Sale sale;

    try {
      sale = Sale.create();
      OpenedSales.add(sale);
    } catch (e) {
      rethrow;
    }

    return sale.uid.toString();
  }
}
