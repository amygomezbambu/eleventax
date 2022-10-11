import 'package:eleventa/modulos/common/app/interface/telemetria.dart';

class AdaptadorDeTelemetriaFake implements IAdaptadorDeTelemetria {
  //TODO: Este fake no esta haciendo nada, por que existe?
  //TODO: Probar los casos de uso que usen estos adaptadores y verificar
  //que esta bien probado
  @override
  Future<void> nuevoEvento(
      {required EventoDeTelemetria evento,
      required Map<String, dynamic> propiedades,
      String? ip}) async {}

  @override
  Future<void> actualizarPerfil(
      {required Map<String, dynamic> propiedades, String? ip}) {
    // TODO: implement actualizarPerfil
    throw UnimplementedError();
  }
}
