import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/dto/sale_item.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/app/mapper/basic_item_mapper.dart';
import 'package:eleventa/modules/sales/app/mapper/sale_mapper.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class AddSaleItemRequest {
  var saleUid = '';
  var item = SaleItemDTO();
}

class AddSaleItem {
  var request = AddSaleItemRequest();
  final ISaleRepository _repo;

  AddSaleItem(this._repo);

  /// Ejecuta el caso de uso
  ///
  /// Retorna los datos actualizados de la venta o una excepción en caso de que no exista la venta
  Future<SaleDTO> exec() async {
    Sale? sale;

    try {
      sale = OpenedSales.get(request.saleUid);

      var saleItem = SaleItemMapper.fromDtoToDomain(request.item);

      sale.addItem(saleItem);

      if (await saleExists(sale.uid.toString())) {
        await _repo.update(sale);
      } else {
        await _repo.add(sale);
      }

      await _repo.addSaleItem(saleItem);
    } catch (e) {
      rethrow;
    }

    return SaleMapper.fromDomainToDTO(sale);
  }

  Future<bool> saleExists(String uid) async {
    var sale = await _repo.get(uid);

    if (sale != null) {
      return true;
    } else {
      return false;
    }
  }
}
