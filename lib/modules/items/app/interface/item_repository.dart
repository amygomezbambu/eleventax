import 'package:eleventa/modules/items/domain/entity/item.dart';

abstract class IItemRepository {
  Future<void> add(Item item);
  Future<Item?> get(String uid);
  Future<Item?> getBySku(String sku);
  Future<List<Item>> getAll();
}
