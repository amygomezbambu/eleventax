import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/infra/sqlite_adapter.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';

class ItemRepository implements IItemRepository {
  late IDatabaseAdapter _db;

  ItemRepository() {
    _db = SQLiteAdapter();
  }

  @override
  Future<void> add(Item item) async {
    var command =
        'INSERT INTO items(uid, sku, description, price) VALUES(?,?,?,?)';

    await _db.command(
        sql: command,
        params: [item.uid, item.sku, item.description, item.price]);
  }

  @override
  Future<Item?> get(String uid) async {
    var query = 'SELECT uid, sku, description, price FROM items WHERE uid = ?';

    var result = await _db.query(sql: query, params: [uid]);
    Item? item;

    for (var row in result) {
      item = Item.load(row['uid'] as String, row['sku'] as String,
          row['description'] as String, row['price'] as double);
    }

    return item;
  }

  @override
  Future<Item?> getBySku(String sku) async {
    var query = 'SELECT uid, sku, description, price FROM items WHERE sku = ?';

    var result = await _db.query(sql: query, params: [sku]);
    Item? item;

    for (var row in result) {
      item = Item.load(row['uid'] as String, row['sku'] as String,
          row['description'] as String, row['price'] as double);
    }

    return item;
  }

  @override
  List<Item> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }
}
