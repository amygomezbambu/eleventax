import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';
import 'package:eleventa/modules/items/app/usecase/get_items.dart';

class ItemsModule {
  static GetItem getItem() {
    return GetItem(Dependencies.sales.itemRepository());
  }

  static GetItems getItems() {
    return GetItems(Dependencies.sales.itemRepository());
  }
}
