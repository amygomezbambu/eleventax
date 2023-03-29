import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/app/interface/remote_config.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/notificaciones/interfaces/repositorio_notificaciones.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';

class _RegistroDeDependencias {
  final Map<String, Object Function()> _deps;

  _RegistroDeDependencias(this._deps);

  T obtenerDependencia<T>() {
    if (_deps.containsKey((T).toString())) {
      var dependencia = _deps[(T).toString()]!();

      return dependencia as T;
    } else {
      throw AssertionError(
          'No se encontró un registro para esta dependencia: ${T.toString()}');
    }
  }
}

class DependenciasDeTelemetria extends _RegistroDeDependencias {
  DependenciasDeTelemetria(Map<String, Object Function()> deps) : super(deps);

  IAdaptadorDeTelemetria adaptador() {
    return obtenerDependencia<IAdaptadorDeTelemetria>();
  }

  IRepositorioTelemetria repositorio() {
    return obtenerDependencia<IRepositorioTelemetria>();
  }
}

class DependenciasDeInfraestructura extends _RegistroDeDependencias {
  DependenciasDeInfraestructura(Map<String, Object Function()> deps)
      : super(deps);

  IAdaptadorDeBaseDeDatos database() {
    return obtenerDependencia<IAdaptadorDeBaseDeDatos>();
  }

  ILogger logger() {
    return obtenerDependencia<ILogger>();
  }

  IRemoteConfig remoteConfig() {
    return obtenerDependencia<IRemoteConfig>();
  }

  ISync sync() {
    return obtenerDependencia<ISync>();
  }

  IAdaptadorDeDispositivo dispositivo() {
    return obtenerDependencia<IAdaptadorDeDispositivo>();
  }

  IRed red() {
    return obtenerDependencia<IRed>();
  }
}

class DependenciasDeVentas extends _RegistroDeDependencias {
  DependenciasDeVentas(Map<String, Object Function()> deps) : super(deps);

  IRepositorioVentas repositorioVentas() {
    return obtenerDependencia<IRepositorioVentas>();
  }

  IRepositorioConsultaVentas repositorioConsultasVentas() {
    return obtenerDependencia<IRepositorioConsultaVentas>();
  }
}

class DependenciasDeProductos extends _RegistroDeDependencias {
  DependenciasDeProductos(Map<String, Object Function()> deps) : super(deps);

  IRepositorioProductos repositorioProductos() {
    return obtenerDependencia<IRepositorioProductos>();
  }

  IRepositorioConsultaProductos repositorioConsultasProductos() {
    return obtenerDependencia<IRepositorioConsultaProductos>();
  }
}

class DependenciasDeNotificaciones extends _RegistroDeDependencias {
  DependenciasDeNotificaciones(Map<String, Object Function()> deps)
      : super(deps);

  IRepositorioNotificaciones repositorioNotificaciones() {
    return obtenerDependencia<IRepositorioNotificaciones>();
  }
}

class Dependencias {
  static final _deps = <String, Object Function()>{};

  static final DependenciasDeInfraestructura infra =
      DependenciasDeInfraestructura(_deps);
  static final DependenciasDeVentas ventas = DependenciasDeVentas(_deps);
  static final DependenciasDeProductos productos =
      DependenciasDeProductos(_deps);

  static final DependenciasDeNotificaciones notificaciones =
      DependenciasDeNotificaciones(_deps);

  static final DependenciasDeTelemetria telemetria =
      DependenciasDeTelemetria(_deps);

  static registrar(String interface, Object Function() builder) {
    _deps.putIfAbsent(interface, () => builder);
  }
}
