import '../../../common/app/usecase/usecase.dart';
import '../../sales_config.dart';
import '../interface/sale_repository.dart';

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
  }
}
