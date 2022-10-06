import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/app/usecase/usecase.dart';

class EnviarMetricasInicialesUseCase extends Usecase<void> {
  final IAdaptadorDeDispositivo _dispositivo;
  final IAdaptadorDeTelemetria _telemetria;

  EnviarMetricasInicialesUseCase(
      {required IAdaptadorDeDispositivo adaptadorDeDispositivo,
      required IAdaptadorDeTelemetria adaptadorDeTelemetria})
      : _dispositivo = adaptadorDeDispositivo,
        _telemetria = adaptadorDeTelemetria {
    operation = _operation;
  }

  Future<void> _operation() async {
    var info = await _dispositivo.obtenerDatos();

    // Los nombres de las propiedades de MixPanel se encuentran en:
    // https://help.mixpanel.com/hc/en-us/articles/115004613766
    await _telemetria.nuevoEvento(EventoDeTelemetria.appIniciada, {
      '\$os': info.so,
      '\$os_version': info.versionSO,
      '\$screen_height': info.altoPantalla,
      '\$screen_width': info.anchoPantalla,
      '\$manufacturer': info.fabricante,
      '\$model': info.modelo,
      '\$device': info.nombre,
      '\$app_version_string': info.appVersion,
      '\$app_build_number': info.appBuild,
      '\$user_id': appConfig.negocioID,
      'Sucursal ID': appConfig.sucursalID,
      'Codigo Pais': info.pais,
      'Lenguaje Dispositivo': info.lenguajeConfigurado,
      'Zona Horaria': info.zonaHoraria,
      'Numero ejecuciones': info.numeroDeEjecuciones,
    });
  }
}
