import 'package:eleventa/loader.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/items/items_module.dart';
import 'package:eleventa/modules/sales/app/dto/sale_item.dart';
import 'package:eleventa/modules/sales/app/dto/sale_dto.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/get_sale.dart';
import 'package:eleventa/modules/sales/domain/service/opened_sales.dart';
import 'package:eleventa/modules/sales/infra/sale_repository.dart';
import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    //En TEST no se carga WidgetsFlutterBinding sino TestWidgetsFlutterBinding
    TestWidgetsFlutterBinding.ensureInitialized();
    Loader loader = Loader();
    await loader.init();
  });

  group('Agregar articulo a venta', () {
    test('debe agregar el articulo a la lista de articulos de la venta',
        () async {
      //having
      var createSale = CreateSale();
      var addItem = AddSaleItem(SaleRepository());
      var quickItem = SaleItemDTO();

      //when
      var uid = createSale.exec();

      quickItem.description = 'coca cola';
      quickItem.price = 10.00;
      quickItem.quantity = 2;

      addItem.request.saleUid = uid;
      addItem.request.item = quickItem;

      var saleDTO = await addItem.exec();

      //then
      expect(saleDTO.saleItems.length, 1);
    });

    test('debe calcular el total correctamente', () async {
      var usecase = CreateSale();
      var addItem = AddSaleItem(SaleRepository());
      var basicItem = SaleItemDTO();

      var uid = usecase.exec();

      basicItem.description = 'coca cola';
      basicItem.price = 10.49;
      basicItem.quantity = 2;

      addItem.request.saleUid = uid;
      addItem.request.item = basicItem;

      await addItem.exec();

      var sale = OpenedSales.get(uid);

      var expectedTotal = 20.98;

      expect(sale.total, expectedTotal);
    });

    test('debe persistir la venta', () async {
      var createSale = CreateSale();
      var addItem = AddSaleItem(SaleRepository());
      var getItems = ItemsModule.getItems();

      var uid = createSale.exec();

      var items = await getItems.exec();

      var dto = SaleItemDTO();
      dto.description = items[0].description;
      dto.itemUid = items[0].uid;
      dto.price = items[0].price;
      dto.quantity = 5;
      dto.saleUid = uid;

      addItem.request.saleUid = uid;
      addItem.request.item = dto;

      await addItem.exec();

      var getSale = GetSale(SaleRepository());
      getSale.request.uid = uid;

      SaleDTO sale = await getSale.exec();

      expect(sale.uid, uid);
      expect(sale.total, items[0].price * 5);
    });

    test('debe revertir la transacción en caso de falla', () async {
      var createSale = CreateSale();
      var addItem = AddSaleItem(SaleRepository());
      var getItems = ItemsModule.getItems();
      var getSale = SalesModule.getSale();

      var uid = createSale.exec();

      var items = await getItems.exec();

      var dto = SaleItemDTO();
      dto.description = items[0].description;
      dto.itemUid = items[0].uid;
      dto.price = items[0].price;
      dto.quantity = 5;
      dto.saleUid = uid;

      addItem.request.saleUid = uid;
      addItem.request.item = dto;

      await addItem.exec();

      addItem = SalesModule.addSaleItem();

      addItem.request.saleUid = uid;
      addItem.request.item = dto;

      await expectLater(
          addItem.exec(), throwsA(isA<InfrastructureException>()));

      getSale.request.uid = uid;
      var sale = await getSale.exec();

      //los totales de la venta aunque se persistieron deben de revertirse ya que
      //trono la transaccion
      expect(sale.total, dto.price * dto.quantity);
    });
  });
}
