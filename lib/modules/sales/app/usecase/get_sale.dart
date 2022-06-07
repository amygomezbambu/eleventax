import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/app/mapper/sale_mapper.dart';

class GetSaleRequest {
  String uid = '';
}

class GetSale {
  var request = GetSaleRequest();
  ISaleRepository repo;

  GetSale(this.repo);

  Future<SaleDTO> exec() async {
    var sale = await repo.get(request.uid);

    if (sale == null) {
      throw Exception('No existe la venta');
    }

    var dto = SaleMapper.fromDomainToDTO(sale);

    return dto;
  }
}
