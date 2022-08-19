import 'package:eleventa/loader.dart';
import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    //En TEST no se carga WidgetsFlutterBinding sino TestWidgetsFlutterBinding
    TestWidgetsFlutterBinding.ensureInitialized();
    Loader loader = Loader();
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
