import '../../../common/app/usecase/usecase.dart';
import '../../sales_config.dart';
import '../interface/sale_repository.dart';

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
