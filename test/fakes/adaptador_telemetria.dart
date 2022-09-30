import 'package:eleventa/modulos/common/app/interface/telemetria.dart';

class AdaptadorDeTelemetriaFake implements IAdaptadorDeTelemetria {
  @override
  Future<void> nuevoEvento(EventoDeTelemetria evento,
      [Map<String, dynamic> propiedades = const {}]) async {}
}
