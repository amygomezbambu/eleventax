import 'package:eleventa/loader.dart';
import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/get_sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';
import 'package:eleventa/modules/sales/infra/sale_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    Loader loader = Loader();
    await loader.init();
  });

  group('Agregar articulo a venta', () {
    test('debe agregar el articulo a la lista de articulos de la venta',
        () async {
      //having
      var createSale = CreateSale();
      var addItem = AddSaleItem(SaleRepository());
      var basicItem = BasicItemDTO();

      //when
      var uid = createSale.exec();

      basicItem.description = 'coca cola';
      basicItem.price = 10.00;
      basicItem.quantity = 2;

      addItem.request.uid = uid;
      addItem.request.item = basicItem;

      var itemsCount = await addItem.exec();

      //then
      expect(itemsCount, 1);
    });

    test('debe calcular el total correctamente', () async {
      var usecase = CreateSale();
      var addItem = AddSaleItem(SaleRepository());
      var basicItem = BasicItemDTO();

      var uid = usecase.exec();

      basicItem.description = 'coca cola';
      basicItem.price = 10.49;
      basicItem.quantity = 2;

      addItem.request.uid = uid;
      addItem.request.item = basicItem;

      await addItem.exec();

      var sale = OpenedSales.get(uid);

      var expectedTotal = 20.98;

      expect(sale.total, expectedTotal);
    });

    test('debe persistir la venta', () async {
      var createSale = CreateSale();
      var addItem = AddSaleItem(SaleRepository());

      var uid = createSale.exec();

      var basicItem = BasicItemDTO();

      basicItem.description = 'coca cola';
      basicItem.price = 10.49;
      basicItem.quantity = 2;

      addItem.request.uid = uid;
      addItem.request.item = basicItem;

      await addItem.exec();

      var getSale = GetSale(SaleRepository());
      getSale.request.uid = uid;

      SaleDTO sale = await getSale.exec();

      expect(sale.uid, uid);
      expect(sale.total, basicItem.price * basicItem.quantity);
    });
  });
}
