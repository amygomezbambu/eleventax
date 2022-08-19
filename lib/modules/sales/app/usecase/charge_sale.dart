import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';

class ChargeSaleRequest {
  late SalePaymentMethod paymentMethod;
  late String saleUid;
}

class ChargeSale extends Usecase<void> {
  final request = ChargeSaleRequest();
  final ISaleRepository _repo;

  ChargeSale(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<void> _doOperation() async {
    var sale = OpenedSales.get(request.saleUid);

    sale.charge(request.paymentMethod);

    await _repo.updateChargeData(sale);
  }
}
