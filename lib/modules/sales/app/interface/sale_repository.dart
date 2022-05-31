import 'package:eleventa/modules/sales/domain/entity/sale.dart';

abstract class ISaleRepository {
  void add(Sale sale);
  Sale get(String uid);
  List<Sale> getAll();
}
