import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class ChargeSaleRequest {
  late SalePaymentMethod paymentMethod;
  late String saleUid;
}

class ChargeSale {
  var request = ChargeSaleRequest();
  final ISaleRepository _repo;

  ChargeSale(this._repo);

  Future<void> exec() async {
    var sale = OpenedSales.get(request.saleUid);

    sale.charge(request.paymentMethod);

    await _repo.updateChargeData(sale);
  }
}
