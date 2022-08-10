import 'package:eleventa/modules/common/domain/valueObject/uid.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';
import '../../common/infra/repository.dart';

class ItemRepository extends Repository implements IItemRepository {
  ItemRepository() : super();

  @override
  Future<void> add(Item item) async {
    var command =
        'INSERT INTO items(uid, sku, description, price) VALUES(?,?,?,?)';

    try {
      await db.command(sql: command, params: [
        item.uid.toString(),
        item.sku,
        item.description,
        item.price
      ]);
    } catch (error, stack) {
      throw InfrastructureException(
          error.toString(), error as Exception, stack);
    }
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
