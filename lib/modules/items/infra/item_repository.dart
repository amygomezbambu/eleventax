import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';
import 'package:eleventa/modules/common/infra/repository.dart';

class ItemRepository extends Repository implements IItemRepository {
  ItemRepository({ISync? sync, IDatabaseAdapter? db}) : super(sync, db);

  @override
  Future<void> add(Item item) async {
    // throw InfrastructureException(
    //   message:
    //       'Ocurrio un error an intentar guardar el producto en la base de datos',
    //   innerException: Exception('No se encuentra el archivo de base de datos'),
    //   stackTrace: StackTrace.current,
    //   input: item.toString(),
    // );

    await sync.syncChanges(
        dataset: 'items',
        rowID: item.uid.toString(),
        columns: ['sku', 'description', 'price'],
        values: [item.sku, item.description, item.price]);
  }

  @override
  Future<Item?> get(String uid) async {
    var query = 'SELECT uid, sku, description, price FROM items WHERE uid = ?';

    var result = await db.query(sql: query, params: [uid]);
    Item? item;

    for (var row in result) {
      item = Item.load(UID(row['uid'] as String), row['sku'] as String,
          row['description'] as String, row['price'] as double);
    }

    return item;
  }

  @override
  Future<Item?> getBySku(String sku) async {
    var query = 'SELECT uid, sku, description, price FROM items WHERE sku = ?';

    var result = await db.query(sql: query, params: [sku]);
    Item? item;

    for (var row in result) {
      item = Item.load(UID(row['uid'] as String), row['sku'] as String,
          row['description'] as String, double.parse(row['price'].toString()));
    }

    return item;
  }

  @override
  Future<List<Item>> getAll() async {
    var query = 'SELECT uid, sku, description, price FROM items';

    var result = await db.query(sql: query);
    var items = <Item>[];

    for (var row in result) {
      items.add(Item.load(UID(row['uid'] as String), row['sku'] as String,
          row['description'] as String, double.parse(row['price'].toString())));
    }

    return items;
  }
}
