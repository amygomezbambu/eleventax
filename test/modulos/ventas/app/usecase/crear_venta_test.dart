import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  // group('Crear Venta', () {
  //   test('Se debe crear la venta con los valores default', () {
  //     var usecase = CrearVenta();

  //     var uuid = usecase.exec();

  //     expect(uuid, isNotEmpty);
  //   });
  // });
}
