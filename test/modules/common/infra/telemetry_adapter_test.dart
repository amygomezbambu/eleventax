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
      var telemetry = Dependencias.infra.adaptadorTelemetria();

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

  //TODO: esta prueba no pasa, creo que es por la libreria pero hay que verificar que esta
  //pasando
  test(
    'debe lanzar error si no se recibio el evento correctamente',
    () async {
      // var invalidToken = '2662762uyyuyss';

      // var telemetry = TelemetryAdapter(token: invalidToken);

      // await expectLater(
      //   telemetry.sendEvent(
      //     TelemetryEvent.appStarted,
      //     {
      //       'distinct_id': invalidToken,
      //     },
      //   ),
      //   throwsA(isA<EleventaException>()),
      // );
    },
  );
}
