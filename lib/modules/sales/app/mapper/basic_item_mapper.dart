import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/sales/app/dto/sale_item.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';

class SaleItemMapper {
  static SaleItem fromDtoToDomain(SaleItemDTO item) {
    return SaleItem(
        itemUid: item.itemUid != null ? UID(item.itemUid!) : null,
        saleUid: UID(item.saleUid),
        description: item.description,
        price: item.price,
        quantity: item.quantity);
  }

  static SaleItemDTO fromDomainToDTO(SaleItem item) {
    var dto = SaleItemDTO();
    dto.saleUid = item.saleUid.toString();
    // ignore: prefer_null_aware_operators
    dto.itemUid = item.itemUid != null ? item.itemUid.toString() : null;
    dto.price = item.price;
    dto.quantity = item.quantity;

    return dto;
  }
}
