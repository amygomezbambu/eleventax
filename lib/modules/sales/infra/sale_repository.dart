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
    var command = 'INSERT INTO sales(uid, name, total, status) VALUES(?,?,?,?)';

    await _db.command(
        sql: command,
        params: [sale.uid, sale.name, sale.total, sale.status.index]);
  }

  @override
  Future<void> updateChargeData(Sale sale) async {
    var command =
        'UPDATE sales set paymentMethod = ?, status = ?, paymentTimeStamp = ? '
        'WHERE uid = ?';

    if (sale.paymentMethod == null) {
      throw Exception('No esta establecido el metodo de pago');
    }

    if (sale.paymentTimeStamp == null) {
      throw Exception('No esta establecida la fecha del pago');
    }

    await _db.command(sql: command, params: [
      sale.paymentMethod!.index,
      sale.status.index,
      sale.paymentTimeStamp!,
      sale.uid,
    ]);
  }

  @override
  Future<void> update(Sale sale) async {
    var command =
        'UPDATE sales set name = ?, total = ?, paymentMethod = ?, status = ?, paymentTimeStamp = ?'
        'WHERE uid = ?';

    if (sale.paymentMethod == null) {
      throw Exception('No esta establecido el metodo de pago');
    }

    if (sale.paymentTimeStamp == null) {
      throw Exception('No esta establecida la fecha del pago');
    }

    await _db.command(sql: command, params: [
      sale.name,
      sale.total,
      sale.paymentMethod!.index,
      sale.status.index,
      sale.paymentTimeStamp!,
      sale.uid,
    ]);
  }

  @override
  Future<Sale?> get(String uid) async {
    var query =
        'SELECT id,uid,name,total,status,paymentMethod,paymentTimeStamp FROM sales '
        'WHERE uid = ?';

    var result = await _db.query(sql: query, params: [uid]);
    Sale? sale;

    for (var row in result) {
      var statusIndex = row['status'] as int;

      sale = Sale.load(
          uid: row['uid'] as String,
          name: row['name'] as String,
          total: row['total'] as double,
          status: SaleStatus.values[statusIndex],
          paymentMethod: row['paymentMethod'] == null
              ? null
              : SalePaymentMethod.values[(row['paymentMethod'] as int)],
          paymentTimeStamp: row['paymentTimeStamp'] == null
              ? null
              : row['paymentTimeStamp'] as int);
    }

    return sale;
  }

  @override
  List<Sale> getAll() {
    throw UnimplementedError();
  }
}
