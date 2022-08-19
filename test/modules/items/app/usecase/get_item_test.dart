import 'package:eleventa/modules/items/items_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.init();
  });

  group('Obtener item', () {
    test('Debe devolver un articulo cuando le demos un SKU válido', () async {
      const sku = '12345';
      final getItem = ItemsModule.getItem();
      final createItem = ItemsModule.createItem();

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
      final getItem = ItemsModule.getItem();

      getItem.request.sku = sku;

      expectLater(getItem.exec(), throwsA(isA<Exception>()));
    });
  });
}
