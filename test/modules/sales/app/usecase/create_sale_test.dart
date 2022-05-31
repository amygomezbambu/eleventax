import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/get_sale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Crear Venta', () {
    test('Se debe crear la venta con los valores default', () {
      var usecase = CreateSale();

      var uuid = usecase.exec();

      expect(uuid, isNotEmpty);
    });

    test('debe persistir la venta cuando tenga 1 y mas articulos', () {
      var createSale = CreateSale();
      var addItem = AddSaleItem();

      var uid = createSale.exec();

      var basicItem = BasicItemDTO();

      basicItem.description = 'coca cola';
      basicItem.price = 10.49;
      basicItem.quantity = 2;

      addItem.request.uid = uid;
      addItem.request.item = basicItem;

      addItem.exec();

      var getSale = GetSale();
      getSale.request.uid = uid;

      SaleDTO sale = getSale.exec();

      expect(sale.uid, uid);
      expect(sale.itemCount, 1);
      expect(sale.total, basicItem.price * basicItem.quantity);
    });
  });
}
