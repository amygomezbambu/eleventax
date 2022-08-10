import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/common/exception/exception.dart';

import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';
import 'package:eleventa/utils/utils.dart';
import '../../common/infra/repository.dart';

class SaleRepository extends Repository implements ISaleRepository {
  SaleRepository() : super();

  @override
  Future<void> add(Sale sale) async {
    var command = 'INSERT INTO sales(uid, name, total, status) VALUES(?,?,?,?)';

    await db.command(sql: command, params: [
      sale.uid.toString(),
      sale.name,
      sale.total,
      sale.status.index
    ]);
  }

  @override
  Future<void> addSaleItem(SaleItem item) async {
    var command =
        'INSERT INTO sale_items(sales_uid, items_uid, quantity) VALUES(?,?,?)';

    try {
      await db.command(sql: command, params: [
        item.saleUid.toString(),
        item.itemUid.toString(),
        item.quantity
      ]);
    } catch (error, stack) {
      throw InfrastructureException(
        error.toString(),
        error as Exception,
        stack,
      );
    }
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

    await db.command(sql: command, params: [
      sale.paymentMethod!.index,
      sale.status.index,
      sale.paymentTimeStamp!,
      sale.uid.toString(),
    ]);
  }

  @override
  Future<void> update(Sale sale) async {
    var command =
        'UPDATE sales set name = ?, total = ?, status = ?, paymentMethod = ?, paymentTimeStamp = ? '
        ' WHERE uid = ?';

    var params = <Object>[];
    params.add(sale.name);
    params.add(sale.total);
    params.add(sale.status.index);

    if (sale.paymentMethod != null) {
      params.add(sale.paymentMethod!.index);
    } else {
      params.add(SalePaymentMethod.notDefined.index);
    }

    if (sale.paymentTimeStamp != null) {
      params.add(sale.paymentTimeStamp!);
    } else {
      params.add(Utils.db.nullTimeStamp);
    }

    params.add(sale.uid.toString());

    await db.command(sql: command, params: params);
  }

  @override
  Future<Sale?> get(String uid) async {
    var query =
        'SELECT uid,name,total,status,paymentMethod,paymentTimeStamp FROM sales '
        'WHERE uid = ?';

    var result = await db.query(sql: query, params: [uid]);
    Sale? sale;

    for (var row in result) {
      var statusIndex = row['status'] as int;

      sale = Sale.load(
          uid: UID(row['uid'] as String),
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
