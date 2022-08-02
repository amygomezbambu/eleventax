import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/app/mapper/sale_mapper.dart';

class GetSaleRequest {
  String uid = '';
}

class GetSale extends Usecase<SaleDTO> {
  var request = GetSaleRequest();
  final ISaleRepository _repo;

  GetSale(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<SaleDTO> _doOperation() async {
    var sale = await _repo.get(request.uid);

    if (sale == null) {
      throw Exception('No existe la venta');
    }

    var dto = SaleMapper.fromDomainToDTO(sale);

    return dto;
  }
}
