import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/sales/sales_config.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';

class GetConfig extends Usecase<SalesConfig> {
  final ISaleRepository _repo;

  GetConfig(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<SalesConfig> _doOperation() async {
    var config = SalesConfig();
    config.shared = await _repo.getSharedConfig();
    return config;
  }
}
