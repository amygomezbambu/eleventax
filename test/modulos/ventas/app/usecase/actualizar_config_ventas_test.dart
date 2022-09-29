import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe actualizar la configuracion si todos los valores son correctos',
      () async {
    //Tener un listado de los valores de configuracion
    var actualizarConfig = ModuloVentas.actualizarConfig();
    var obtenerConfig = ModuloVentas.obtenerConfig();

    var configRequest = actualizarConfig.req.config;

    configRequest.compartida.permitirProductoComun = false;
    configRequest.local.permitirDescuentos = false;

    await actualizarConfig.exec();

    //leerlos u obtener y verificar que si se guardo la informacion
    var config = await obtenerConfig.exec();

    expect(config.compartida.permitirProductoComun, false);
    expect(config.local.permitirDescuentos, false);
  });
}
