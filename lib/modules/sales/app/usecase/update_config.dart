import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/sales/sales_config.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';

class UpdateConfigRequest {
  var config = SalesConfig();
}

class UpdateConfig extends Usecase<void> {
  final request = UpdateConfigRequest();
  final ISaleRepository _repo;

  UpdateConfig(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<void> _doOperation() async {
    await _repo.saveSharedConfig(request.config.shared);
    await request.config.local.save();
  }
}
