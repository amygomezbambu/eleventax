import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/app/mapper/basic_item_mapper.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class AddSaleItemRequest {
  String saleUid = '';
  late BasicItemDTO item;
}

class AddSaleItem {
  var request = AddSaleItemRequest();
  ISaleRepository _repo;

  AddSaleItem(this._repo);

  /// Ejecuta el caso de uso
  ///
  /// Retorna el numero de items de la venta despues de agregar
  Future<int> exec() async {
    Sale? sale;

    try {
      sale = OpenedSales.get(request.saleUid);
      sale.addItem(BasicItemMapper.fromDtoToDomain(request.item));
      await _repo.add(sale);
    } catch (e) {
      rethrow;
    }

    return (sale != null) ? sale.itemsCount : 0;
  }
}
