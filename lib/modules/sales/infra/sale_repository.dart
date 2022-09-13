import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/common/utils/utils.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/domain/entity/sale_item.dart';
import 'package:eleventa/modules/common/infra/repository.dart';
import 'package:eleventa/modules/sales/sales_config.dart';

class SaleRepository extends Repository implements ISaleRepository {
  final syncModuleName = 'sales';
  final tableName = 'sales';

  SaleRepository({required ISync syncAdapter, required IDatabaseAdapter db})
      : super(syncAdapter, db);

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
        message:
            'Ocurrio un error al intentar almacenar el articulo de venta en la base de datos.',
        innerException: error as Exception,
        stackTrace: stack,
        input: item.toString(),
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

    var params = <Object?>[];
    params.add(sale.name);
    params.add(sale.total);
    params.add(sale.status.index);

    if (sale.paymentMethod != null) {
      params.add(sale.paymentMethod!.index);
    } else {
      params.add(SalePaymentMethod.notDefined.index);
    }

    params.add(sale.paymentTimeStamp);

    params.add(sale.uid.toString());

    await db.command(sql: command, params: params);
  }

  @override
  Future<Sale?> getSingle(UID uid) async {
    var query =
        'SELECT uid,name,total,status,paymentMethod,paymentTimeStamp FROM sales '
        'WHERE uid = ?';

    var result = await db.query(sql: query, params: [uid.toString()]);
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
  Future<void> delete(UID id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Sale>> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveSharedConfig(SalesSharedConfig config) async {
    //var command = 'INSERT OR REPLACE INTO config(uid,module, value) VALUES (?, ?);';

    //await db.command(sql: command, params: ['sales', jsonEncode(config)]);

    await syncAdapter.synchronize(
      dataset: 'sales_config',
      rowID: config.uid.toString(),
      fields: {
        'allowQuickItem': config.allowQuickItem,
        'allowZeroCost': config.allowZeroCost
      },
    );
  }

  @override
  Future<SalesSharedConfig> getSharedConfig() async {
    SalesSharedConfig sharedConfig;

    var query = 'SELECT * FROM sales_config';

    var dbResult = await db.query(sql: query);

    if (dbResult.length == 1) {
      sharedConfig = SalesSharedConfig.load(
          uid: UID(dbResult.first['uid'].toString()),
          allowQuickItem:
              Utils.db.intToBool(dbResult.first['allowQuickItem'] as int),
          allowZeroCost: Utils.db.intToBool(dbResult.first['allowZeroCost'] as int));
    } else {
      throw EleventaException(
          message: 'No hay valores de configuración del módulo');
    }

    return sharedConfig;
  }
}
