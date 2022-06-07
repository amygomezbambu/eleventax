import 'package:eleventa/loader.dart';
import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/get_sale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    Loader loader = Loader();
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
