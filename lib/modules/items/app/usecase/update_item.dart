import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';

class UpdateItemRequest {
  ItemDTO item = ItemDTO();
}

class UpdateItem extends Usecase<void> {
  var req = UpdateItemRequest();
  final IItemRepository _repo;

  UpdateItem(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<void> _doOperation() async {
    var item = Item.load(
      UID(req.item.uid),
      req.item.sku,
      req.item.description,
      req.item.price,
    );

    await _repo.update(item);
  }
}
