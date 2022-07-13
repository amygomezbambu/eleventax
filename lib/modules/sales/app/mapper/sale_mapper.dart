import 'package:eleventa/modules/sales/app/dto/sale_item.dart';
import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/mapper/basic_item_mapper.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class SaleMapper {
  static SaleDTO fromDomainToDTO(Sale sale) {
    var dto = SaleDTO();
    dto.name = sale.name;
    dto.total = sale.total;
    dto.uid = sale.uid.toString();
    dto.paymentMethod = sale.paymentMethod;
    dto.paymentTimeStamp = sale.paymentTimeStamp;
    dto.status = sale.status;

    dto.saleItems = <SaleItemDTO>[];

    for (var item in sale.saleItems) {
      dto.saleItems.add(SaleItemMapper.fromDomainToDTO(item));
    }

    return dto;
  }
}
