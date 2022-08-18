import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';

class UpdateItemRequest {
  late UID uid;
  String sku = '';
  String description = '';
  double price = 0.00;
}

class UpdateItem extends Usecase<void> {
  var req = UpdateItemRequest();
  final IItemRepository _repo;

  UpdateItem(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<void> _doOperation() async {
    var item = Item.load(req.uid, req.sku, req.description, req.price);

    await _repo.update(item);
  }
}
