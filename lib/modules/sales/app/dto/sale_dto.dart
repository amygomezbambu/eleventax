import 'package:eleventa/modules/sales/app/dto/basic_item.dart';

import '../../domain/entity/sale.dart';

class SaleDTO {
  var uid = '';
  var name = '';
  var total = 0.0;
  var status = SaleStatus.open;
  SalePaymentMethod? paymentMethod;
  int? paymentTimeStamp;
  var saleItems = <BasicItemDTO>[];
}
