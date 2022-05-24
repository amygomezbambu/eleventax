import 'package:eleventa/modules/sales/domain/entity/basic_item.dart';
import 'package:uuid/uuid.dart';

class Sale {
  final String _uuid = const Uuid().v4();
  var _name = '';
  var _total = 0.0;
  var _saleItems = <BasicItem>[];

  String get uuid {
    return _uuid;
  }

  Sale();
}
