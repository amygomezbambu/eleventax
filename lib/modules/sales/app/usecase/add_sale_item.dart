import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/mapper/basic_item_mapper.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class AddSaleItemRequest {
  String uid = '';
  late BasicItemDTO item;
}

class AddSaleItem {
  var request = AddSaleItemRequest();

  int exec() {
    Sale? sale;

    try {
      sale = OpenedSales.get(request.uid);
      sale.addItem(BasicItemMapper.fromDtoToDomain(request.item));
    } catch (e) {}

    return (sale != null) ? sale.itemsCount : 0;
  }
}
