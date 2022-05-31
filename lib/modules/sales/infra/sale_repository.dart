import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/infra/sqlite_adapter.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class SaleRepository implements ISaleRepository {
  late IDatabaseAdapter _db;

  SaleRepository() {
    _db = SQLiteAdapter();
  }

  @override
  Future<void> add(Sale sale) async {
    var command = 'INSERT INTO sales(uid, name, total) VALUES(?,?,?)';

    await _db.command(sql: command, params: [sale.uid, sale.name, sale.total]);
  }

  @override
  Future<Sale> get(String uid) async {
    var query = 'SELECT id,uid,name,total FROM sales';

    var result = await _db.query(sql: query);
    Sale sale = Sale();

    for (var row in result) {
      sale.total = row['total'] as double;
      sale.name = row['name'] as String;
      sale.uid = row['uid'] as String;
    }
  }

  @override
  List<Sale> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }
}
