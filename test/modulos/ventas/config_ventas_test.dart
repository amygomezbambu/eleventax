import 'package:flutter_test/flutter_test.dart';

import '../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe actualizar la configuracion si todos los valores son correctos',
      () async {
    // var config = ModuloVentas.config;

    // config.compartida.permitirProductoComun = false;
    // config.local.permitirDescuentos = true;

    // await config.guardar();
    // await config.leer();

    // expect(config.compartida.permitirProductoComun, false);
    // expect(config.local.permitirDescuentos, true);
  });
}
