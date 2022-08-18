import 'package:eleventa/modules/common/domain/entity.dart';
import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';

enum SaleStatus { open, paid, cancelled }

enum SalePaymentMethod { notDefined, cash }

class Sale extends Entity {
  UID _uid = UID();
  var _name = '';
  var _total = 0.0;
  final _saleItems = <SaleItem>[];
  SalePaymentMethod? _paymentMethod;
  int? _paymentTimeStamp;
  SaleStatus _status = SaleStatus.open;

  UID get uid => _uid;
  double get total => _total;
  String get name => _name;
  SalePaymentMethod? get paymentMethod => _paymentMethod;
  int? get paymentTimeStamp => _paymentTimeStamp;
  SaleStatus get status => _status;

  List<SaleItem> get saleItems => List.unmodifiable(_saleItems);
  int get itemsCount => _saleItems.length;

  Sale();

  Sale.load(
      {required UID uid,
      required String name,
      required double total,
      required SaleStatus status,
      SalePaymentMethod? paymentMethod,
      int? paymentTimeStamp,
      List<SaleItem>? items}) {
    _uid = uid;
    _name = name;
    _total = total;
    _status = status;
    _paymentMethod = paymentMethod;
    _paymentTimeStamp = paymentTimeStamp;
  }

  void addItem(SaleItem item) {
    _saleItems.add(item);

    calculateTotal();
  }

  void charge(SalePaymentMethod paymentMethod) {
    _paymentMethod = paymentMethod;
    _paymentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    _status = SaleStatus.paid;
  }

  void calculateTotal() {
    _total = 0.0;

    for (var item in _saleItems) {
      _total += item.total;
    }
  }
}
