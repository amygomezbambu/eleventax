import 'package:eleventa/modulos/telemetria/modulo_telemetria.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    //PackageInfo.setMockInitialValues(appName: "abc", packageName: "com.example.example", version: "1.0", buildNumber: "2", buildSignature: "buildSignature");

    final loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe enviar las metricas iniciales al abrir el programa', () async {
    var enviarMetricas = ModuloTelemetria.enviarMetricasIniciales();

    await expectLater(
      enviarMetricas.exec(),
      completes,
    );
  });
}
