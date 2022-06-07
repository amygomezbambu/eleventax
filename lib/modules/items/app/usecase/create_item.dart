import '../interface/item_repository.dart';
import '../../domain/entity/item.dart';

class CreateItemRequest {
  String sku = '';
  String description = '';
  double price = 0.00;
}

class CreateItem {
  final IItemRepository _repo;
  CreateItemRequest request = CreateItemRequest();

  CreateItem(this._repo);

  Future<String> exec() async {
    Item item = Item(
        sku: request.sku,
        description: request.description,
        price: request.price);

    await _repo.add(item);

    return item.uid;
  }
}
