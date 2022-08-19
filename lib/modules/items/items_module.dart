import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/items/app/usecase/create_item.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';
import 'package:eleventa/modules/items/app/usecase/get_items.dart';
import 'package:eleventa/modules/items/app/usecase/update_item.dart';

class ItemsModule {
  static GetItem getItem() {
    return GetItem(Dependencies.sales.itemRepository());
  }

  static GetItems getItems() {
    return GetItems(Dependencies.sales.itemRepository());
  }

  static CreateItem createItem() {
    return CreateItem(Dependencies.sales.itemRepository());
  }

  static UpdateItem updateItem() {
    return UpdateItem(Dependencies.sales.itemRepository());
  }
}
