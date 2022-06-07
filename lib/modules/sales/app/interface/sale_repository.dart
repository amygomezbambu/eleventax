import 'package:eleventa/modules/sales/domain/entity/sale.dart';

abstract class ISaleRepository {
  Future<void> add(Sale sale);
  Future<Sale?> get(String uid);
  List<Sale> getAll();
}
