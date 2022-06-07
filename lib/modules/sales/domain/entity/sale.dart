import 'package:eleventa/modules/sales/domain/entity/basic_item.dart';
import 'package:uuid/uuid.dart';

class Sale {
  String _uid = const Uuid().v4();
  var _name = '';
  var _total = 0.0;
  var _saleItems = <BasicItem>[];

  String get uid => _uid;
  double get total => _total;
  String get name => _name;
  List<BasicItem> get saleItems => List.unmodifiable(_saleItems);
  int get itemsCount => _saleItems.length;

  Sale();

  Sale.load(String uid, String name, double total, List<BasicItem>? items) {
    _uid = uid;
    _name = name;
    _total = total;
  }

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
