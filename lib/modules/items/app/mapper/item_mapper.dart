import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';

class ItemMapper {
  static ItemDTO fromDomainToDTO(Item item) {
    var dto = ItemDTO();
    dto.description = item.description;
    dto.price = item.price;
    dto.sku = item.sku;
    dto.uid = item.uid;

    return dto;
  }
}
