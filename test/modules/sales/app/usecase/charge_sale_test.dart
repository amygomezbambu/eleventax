import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.init();
  });

  group('Cobrar venta', () {
    test('Se debe registrar el tipo de pago y la fecha del cobro', () async {
      var chargeSale = SalesModule.chargeSale();
      //crear venta
      var createSale = SalesModule.createSale();
      var addItem = SalesModule.addSaleItem();

      //when
      final uid = createSale.exec();

      addItem.request.item.description = 'coca cola';
      addItem.request.item.price = 10.56;
      addItem.request.item.quantity = 2;

      addItem.request.saleUid = uid;

      await addItem.exec();

      chargeSale.request.saleUid = uid;
      chargeSale.request.paymentMethod = SalePaymentMethod.cash;

      await chargeSale.exec();

      var getSale = SalesModule.getSale();
      getSale.request.uid = uid;
      var saleDTO = await getSale.exec();
      //expect

      //expect(saleDTO.status, SaleStatus.paid);
      expect(saleDTO.paymentMethod, SalePaymentMethod.cash);
      expect(saleDTO.paymentTimeStamp, greaterThan(0));
    });

    test('Se debe marcar la venta como cobrada', () {});
  });
}
