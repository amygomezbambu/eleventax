import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

class QuickSaleItem extends SaleItem {
  QuickSaleItem(
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
