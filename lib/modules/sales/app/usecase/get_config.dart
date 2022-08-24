import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/sales/app/interface/local_config_adapter.dart';
import 'package:eleventa/modules/sales/sales_config.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';

class GetConfig extends Usecase<SalesConfig> {
  final ISaleRepository _repo;
  final ISaleLocalConfigAdapter _localConfigAdapter;

  GetConfig(this._repo, this._localConfigAdapter) : super(_repo) {
    operation = _doOperation;
  }

  Future<SalesConfig> _doOperation() async {
    var config = SalesConfig();

    config.shared = await _repo.getSharedConfig();
    config.local = await _localConfigAdapter.read();

    return config;
  }
}
