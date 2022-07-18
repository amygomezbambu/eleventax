import 'package:eleventa/container.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';
import 'package:eleventa/modules/items/app/usecase/get_items.dart';

class ItemsModule {
  static GetItem getItem() {
    return GetItem(Dependencies.items.itemRepository());
  }

  static GetItems getItems() {
    return GetItems(Dependencies.items.itemRepository());
  }
}
