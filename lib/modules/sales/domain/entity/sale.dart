import 'package:eleventa/modules/sales/domain/entity/basic_item.dart';
import 'package:eleventa/utils/utils.dart';

enum SaleStatus { open, paid, cancelled }

enum SalePaymentMethod { cash, credit, creditCard, bankTransfer, voucher }

class Sale {
  String _uid = Utils.uid.generate();
  var _name = '';
  var _total = 0.0;
  final _saleItems = <BasicItem>[];
  SalePaymentMethod? _paymentMethod;
  int? _paymentTimeStamp;
  SaleStatus _status = SaleStatus.open;

  String get uid => _uid;
  double get total => _total;
  String get name => _name;
  SalePaymentMethod? get paymentMethod => _paymentMethod;
  int? get paymentTimeStamp => _paymentTimeStamp;
  SaleStatus get status => _status;

  List<BasicItem> get saleItems => List.unmodifiable(_saleItems);
  int get itemsCount => _saleItems.length;

  Sale();

  Sale.load(
      {required String uid,
      required String name,
      required double total,
      required SaleStatus status,
      SalePaymentMethod? paymentMethod,
      int? paymentTimeStamp,
      List<BasicItem>? items}) {
    _uid = uid;
    _name = name;
    _total = total;
    _status = status;
    _paymentMethod = paymentMethod;
    _paymentTimeStamp = paymentTimeStamp;
  }

  void addItem(BasicItem item) {
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
