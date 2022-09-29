import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe generar los datos iniciales si no existen.', () async {
    AppConfig appConfig = AppConfig();

    await appConfig.cargar();

    expect(appConfig.deviceId, isNotNull);
  });

  test('debe reutilizar el mismo deviceId si ya existe', () async {
    final uid = UID();

    AppConfig appConfig = AppConfig();

    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', uid.toString());

    await appConfig.cargar();

    expect(appConfig.deviceId, uid);
  });
}
