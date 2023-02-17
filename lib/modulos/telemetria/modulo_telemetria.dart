import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/telemetria/usecase/enviar_metricas_de_cobro.dart';
import 'package:eleventa/modulos/telemetria/usecase/enviar_metricas_iniciales/enviar_metricas_iniciales.dart';

class ModuloTelemetria {
  static EnviarMetricasInicialesUseCase enviarMetricasIniciales() {
    return EnviarMetricasInicialesUseCase(
      adaptadorDeDispositivo: Dependencias.infra.dispositivo(),
      adaptadorDeTelemetria: Dependencias.telemetria.adaptador(),
      repo: Dependencias.telemetria.repositorio(),
    );
  }

  static EnviarMetricasDeCobro enviarMetricasDeCobro() {
    return EnviarMetricasDeCobro(
      adaptadorDeDispositivo: Dependencias.infra.dispositivo(),
      adaptadorDeTelemetria: Dependencias.telemetria.adaptador(),
      repo: Dependencias.telemetria.repositorio(),
    );
  }
}
