import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    final loader = TestsLoader();
    await loader.iniciar();
  });
  test(
    'debe enviar los eventos si esta configurado correctamente',
    () async {
      var telemetry = Dependencias.infra.telemetria();

      //NOTA: tuve que pasarle el distinct_id de esta maner porque por alguna razon no
      //lo estaba obteniendo correctamente, creo que porque al ser un stream y no tener un
      //await la prueba corria tan rapido que el valor asignado al stream no alcanza a
      //asignarse antes de que el envio de la metrica se realice.
      await expectLater(
        telemetry.nuevoEvento(
          EventoDeTelemetria.appIniciada,
          {
            'distinct_id': appConfig.deviceId.toString(),
          },
        ),
        completes,
      );
    },
  );
}
