import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class OpenedSales {
  static final List<Sale> _sales = <Sale>[];

  OpenedSales();

  static void add(Sale sale) {
    _sales.add(sale);
  }

  static void remove(String uuid) {
    var saleToRemove = _sales.firstWhere((sale) => sale.uuid == uuid);

    _sales.remove(saleToRemove);
  }

  static Sale get(String uid) {
    return _sales.firstWhere((sale) => sale.uuid == uid);
  }
}
