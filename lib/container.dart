import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/infra/sqlite_adapter.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/infra/item_repository.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/infra/sale_repository.dart';

class InfraStructureDependencies {
  IDatabaseAdapter database() {
    return SQLiteAdapter();
  }
}

class SalesDependencies {
  ISaleRepository saleRepository() {
    return SaleRepository();
  }
}

class ItemsDependencies {
  IItemRepository itemRepository() {
    return ItemRepository();
  }
}

class Dependencies {
  static final InfraStructureDependencies infra = InfraStructureDependencies();
  static final SalesDependencies sales = SalesDependencies();
  static final ItemsDependencies items = ItemsDependencies();
}
