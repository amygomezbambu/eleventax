import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/mapper/basic_item_mapper.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class SaleMapper {
  static SaleDTO fromDomainToDTO(Sale sale) {
    var dto = SaleDTO();
    dto.name = sale.name;
    dto.total = sale.total;
    dto.uid = sale.uid;

    dto.saleItems = <BasicItemDTO>[];

    for (var item in sale.saleItems) {
      dto.saleItems.add(BasicItemMapper.fromDomainToDTO(item));
    }

    return dto;
  }
}
