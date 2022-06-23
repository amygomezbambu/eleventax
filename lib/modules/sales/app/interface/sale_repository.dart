import 'package:eleventa/modules/sales/domain/entity/sale.dart';

abstract class ISaleRepository {
  Future<void> add(Sale sale);
  Future<Sale?> get(String uid);
  Future<void> update(Sale sale);
  Future<void> updateChargeData(Sale sale);
  List<Sale> getAll();
}
