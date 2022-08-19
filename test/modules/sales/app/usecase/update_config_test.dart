import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.init();
  });

  test('debe actualizar la configuracion si todos los valores son correctos',
      () async {
    //Tener un listado de los valores de configuracion
    var updateConfig = SalesModule.updateConfig();
    var getConfig = SalesModule.getConfig();

    updateConfig.request.config.shared.allowQuickItem = false;

    await updateConfig.exec();

    //leerlos u obtener y verificar que si se guardo la informacion
    var config = await getConfig.exec();

    expect(config.shared.allowQuickItem, false);
  });
}
