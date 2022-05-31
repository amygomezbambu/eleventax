import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Agregar articulo a venta', () {
    test('debe agregar el articulo a la lista de articulos de la venta', () {
      //having
      var createSale = CreateSale();
      var addItem = AddSaleItem();
      var basicItem = BasicItemDTO();

      //when
      var uid = createSale.exec();

      basicItem.description = 'coca cola';
      basicItem.price = 10.00;
      basicItem.quantity = 2;

      addItem.request.uid = uid;
      addItem.request.item = basicItem;

      var itemsCount = addItem.exec();

      //then
      expect(itemsCount, 1);
    });

    test('debe calcular el total correctamente', () {
      var usecase = CreateSale();
      var addItem = AddSaleItem();
      var basicItem = BasicItemDTO();

      var uid = usecase.exec();

      basicItem.description = 'coca cola';
      basicItem.price = 10.49;
      basicItem.quantity = 2;

      addItem.request.uid = uid;
      addItem.request.item = basicItem;

      addItem.exec();

      var sale = OpenedSales.get(uid);

      var expectedTotal = 20.98;

      expect(sale.total, expectedTotal);
    });
  });
}
