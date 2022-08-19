import 'package:eleventa/modules/items/items_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.init();
  });

  test('debe actualizar el item si los parametros son correctos', () async {
    var updateItem = ItemsModule.updateItem();
    var createItem = ItemsModule.createItem();
    var getItem = ItemsModule.getItem();

    const sku = '123456';
    const description = 'Atun tunny 200 grs.';
    const updatedPrice = 13.40;

    createItem.request.sku = sku;
    createItem.request.description = description;
    createItem.request.price = 10.50;

    var uid = await createItem.exec();

    updateItem.req.item.uid = uid.toString();
    updateItem.req.item.sku = sku;
    updateItem.req.item.description = description;
    updateItem.req.item.price = updatedPrice;

    await updateItem.exec();

    getItem.request.sku = sku;
    final item = await getItem.exec();

    expect(item.price, updatedPrice);
  });
}
