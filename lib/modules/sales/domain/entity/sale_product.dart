import 'package:eleventa/modules/common/domain/valueObject/uid.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';

class SaleProduct extends SaleItem {
  SaleProduct(
      {required UID saleUid,
      required UID itemUid,
      required String description,
      required double price,
      required double quantity})
      : super(
            saleUid: saleUid,
            itemUid: itemUid,
            description: description,
            quantity: quantity,
            price: price);
}
