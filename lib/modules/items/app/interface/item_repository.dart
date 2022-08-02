import 'package:eleventa/modules/items/domain/entity/item.dart';
import '../../../common/app/interface/repository.dart';

abstract class IItemRepository extends IRepository {
  Future<void> add(Item item);
  Future<Item?> get(String uid);
  Future<Item?> getBySku(String sku);
  Future<List<Item>> getAll();
}
