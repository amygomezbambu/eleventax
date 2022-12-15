import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/telemetria/entidad/evento_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';

class EnviarMetricasInicialesUseCase extends Usecase<void> {
  final IAdaptadorDeDispositivo _dispositivo;
  final IAdaptadorDeTelemetria _telemetria;
  final IRepositorioTelemetria _repo;

  EnviarMetricasInicialesUseCase({
    required IAdaptadorDeDispositivo adaptadorDeDispositivo,
    required IAdaptadorDeTelemetria adaptadorDeTelemetria,
    required IRepositorioTelemetria repo,
  })  : _dispositivo = adaptadorDeDispositivo,
        _telemetria = adaptadorDeTelemetria,
        _repo = repo {
    operation = _operation;
  }

  Future<void> _operation() async {
    EventoTelemetria evento;

    var conexionDisponible = await Utils.red.hayConexionAInternet();
    var info = await _dispositivo.obtenerDatos();

    if (info.numeroDeEjecuciones == 1) {
      evento = EventoTelemetria(
        uid: UID(),
        esPerfil: true,
        ip: info.ip,
        propiedades: {
          '\$distinct_id': appConfig.deviceId.toString(),
        },
      );

      if (conexionDisponible) {
        await _telemetria.actualizarPerfil(evento);
      } else {
        await _repo.agregarAQueue(evento);
      }
    }

    // Los nombres de las propiedades de MixPanel se encuentran en:
    // https://help.mixpanel.com/hc/en-us/articles/115004613766
    evento = EventoTelemetria(
      uid: UID(),
      tipo: TipoEventoTelemetria.appIniciada,
      ip: info.ip,
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
    );

    if (conexionDisponible) {
      await _telemetria.nuevoEvento(evento);
    } else {
      await _repo.agregarAQueue(evento);
    }
  }
}
