import 'package:eleventa/container.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';

class ItemsModule {
  static GetItem getItem() {
    return GetItem(Dependencies.items.itemRepository());
  }
}
