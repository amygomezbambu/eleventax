import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

import '../interface/item_repository.dart';
import '../../domain/entity/item.dart';

class CreateItemRequest {
  String sku = '';
  String description = '';
  double price = 0.00;
}

class CreateItem extends Usecase<UID> {
  final IItemRepository _repo;
  CreateItemRequest request = CreateItemRequest();

  CreateItem(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<UID> _doOperation() async {
    Item item = Item(
      sku: request.sku,
      description: request.description,
      price: request.price,
    );

    await _repo.add(item);

    return item.uid;
  }
}
