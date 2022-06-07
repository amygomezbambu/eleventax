import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class OpenedSales {
  static final List<Sale> _sales = <Sale>[];

  OpenedSales();

  static void add(Sale sale) {
    _sales.add(sale);
  }

  static void remove(String uid) {
    var saleToRemove = _sales.firstWhere((sale) => sale.uid == uid);

    _sales.remove(saleToRemove);
  }

  static Sale get(String uid) {
    return _sales.firstWhere((sale) => sale.uid == uid);
  }
}
