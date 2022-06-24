import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/app/mapper/basic_item_mapper.dart';
import 'package:eleventa/modules/sales/app/mapper/sale_mapper.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class AddSaleItemRequest {
  String saleUid = '';
  BasicItemDTO item = BasicItemDTO();
}

class AddSaleItem {
  var request = AddSaleItemRequest();
  final ISaleRepository _repo;

  AddSaleItem(this._repo);

  /// Ejecuta el caso de uso
  ///
  /// Retorna los datos de la venta o una excepción en caso de que no exista la venta
  Future<SaleDTO> exec() async {
    Sale? sale;

    try {
      sale = OpenedSales.get(request.saleUid);
      sale.addItem(BasicItemMapper.fromDtoToDomain(request.item));
      await _repo.add(sale);
    } catch (e) {
      rethrow;
    }

    if (sale == null) {
      throw AppException('La venta no existe');
    }

    return SaleMapper.fromDomainToDTO(sale);
  }
}
