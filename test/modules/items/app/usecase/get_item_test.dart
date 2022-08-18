import 'package:eleventa/loader.dart';
import 'package:eleventa/modules/items/infra/item_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eleventa/modules/items/app/usecase/create_item.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';

void main() {
  setUpAll(() async {
    Loader loader = Loader();
    await loader.init();
  });

  group('Obtener item', () {
    test('Debe devolver un articulo cuando le demos un SKU válido', () async {
      const sku = '12345';
      final getItem = GetItem(ItemRepository());
      final createItem = CreateItem(ItemRepository());

      createItem.request.sku = sku;
      createItem.request.description = 'Coca Cola 600ml';
      createItem.request.price = 10.50;

      var uid = await createItem.exec();

      getItem.request.sku = sku;
      final item = await getItem.exec();

      expect(item.sku, sku);
      expect(item.uid, uid.toString());
    });

    test('Debe lanzar excepcion cuando proporcionemos un SKU inválido',
        () async {
      const sku = 'NO-EXISTE-EN-BD';
      final getItem = GetItem(ItemRepository());

      getItem.request.sku = sku;
      //final item = await getItem.exec();

      expectLater(getItem.exec(), throwsA(isA<Exception>()));
    });
  });
}
