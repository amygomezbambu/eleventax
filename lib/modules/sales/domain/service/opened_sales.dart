import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class OpenedSales {
  static final List<Sale> _sales = <Sale>[];

  OpenedSales();

  void add(Sale sale) {
    _sales.add(sale);
  }

  void remove(String uuid) {
    var saleToRemove = _sales.firstWhere((element) => element.uuid == uuid);

    _sales.remove(saleToRemove);
  }
}
