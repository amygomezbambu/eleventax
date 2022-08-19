import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.init();
  });

  group('Crear Venta', () {
    test('Se debe crear la venta con los valores default', () {
      var usecase = CreateSale();

      var uuid = usecase.exec();

      expect(uuid, isNotEmpty);
    });
  });
}
