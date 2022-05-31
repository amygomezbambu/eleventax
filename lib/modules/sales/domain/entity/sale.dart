import 'package:eleventa/modules/sales/domain/entity/basic_item.dart';
import 'package:uuid/uuid.dart';

class Sale {
  final String _uuid = const Uuid().v4();
  var _name = '';
  var _total = 0.0;
  var _saleItems = <BasicItem>[];

  String get uid => _uuid;
  double get total => _total;
  String get name => _name;
  List<BasicItem> get saleItems => List.unmodifiable(_saleItems);
  int get itemsCount => _saleItems.length;

  Sale();

  void addItem(BasicItem item) {
    _saleItems.add(item);

    calculateTotal();
  }

  void calculateTotal() {
    _total = 0.0;

    for (var item in _saleItems) {
      _total += item.total;
    }
  }
}
