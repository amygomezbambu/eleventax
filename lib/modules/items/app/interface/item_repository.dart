import 'package:eleventa/modules/items/domain/entity/item.dart';
import 'package:eleventa/modules/common/app/interface/repository.dart';

abstract class IItemRepository extends IRepository<Item> {
  Future<Item?> getBySku(String sku);
}
