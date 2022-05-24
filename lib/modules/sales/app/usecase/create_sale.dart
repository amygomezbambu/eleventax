import 'package:eleventa/modules/sales/domain/entity/sale.dart';

class CreateSaleRequest {
  int cashierId = 0;
  int deviceId = 0;
}

class CreateSaleResponse {}

class CreateSale {
  var request = CreateSaleRequest();

  String exec() {
    //crear una entidad Sale
    Sale sale;

    try {
      sale = Sale();
    } catch (e) {
      rethrow;
    }

    //retornar el id a la ui
    return sale.uuid;
  }
}
