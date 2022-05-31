import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/domain/entity/basic_item.dart';

class BasicItemMapper {
  static BasicItem fromDtoToDomain(BasicItemDTO item) {
    return BasicItem(
        description: item.description,
        price: item.price,
        quantity: item.quantity);
  }

  static BasicItemDTO fromDomainToDTO(BasicItem item) {
    var dto = BasicItemDTO();
    dto.description = item.description;
    dto.price = item.price;
    dto.quantity = item.quantity;

    return dto;
  }
}
