import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

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
    if (!(await Utils.red.hayConexionAInternet())) {
      // TODO: Almacenar en una cola los eventos pendientes por enviar
      return;
    }

    var info = await _dispositivo.obtenerDatos();

    if (info.numeroDeEjecuciones == 1) {
      await _telemetria.actualizarPerfil(
        propiedades: {
          // En MixPanel un usuario equivale a un dispositivo
          '\$distinct_id': appConfig.deviceId.toString(),
          //'\$email': appConfig.negocio.propietario.correo,
          //'\$name': appConfig.negocio.nombre,
          //'\$first_name': appConfig.negocio.propietario.nombres,
          //'\$last_name': appConfig.negocio.propietario.apellido,
          //'NegocioID': appConfig.negocioID,
        },
        ip: info.ip,
      );
    }

    // Los nombres de las propiedades de MixPanel se encuentran en:
    // https://help.mixpanel.com/hc/en-us/articles/115004613766
    await _telemetria.nuevoEvento(
        evento: EventoDeTelemetria.appIniciada,
        propiedades: {
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
        },
        ip: info.ip);
  }
}
