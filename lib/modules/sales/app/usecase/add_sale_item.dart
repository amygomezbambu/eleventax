import 'package:eleventa/modules/sales/domain/entity/basic_item.dart';

class AddSaleItemRequest {
  String ventaUUID = '';
  late BasicItem item;
}

class AddSaleItem {
  var request = AddSaleItemRequest();

  void exec() {
    //debe agregar el item a la lista de items de la venta
    try {} catch (e) {}

    //debe recalcular el total de la venta
  }
}
