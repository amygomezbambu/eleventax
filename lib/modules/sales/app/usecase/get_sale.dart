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

  SaleDTO exec() {
    var sale = repo.get(request.uid);

    return SaleMapper.fromDomainToDTO(sale);
  }
}
