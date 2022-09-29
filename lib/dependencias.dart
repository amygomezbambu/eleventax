import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/ventas/app/interface/adaptador_de_config_local.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';

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

class DependenciasDeInfraestructura extends _RegistroDeDependencias {
  DependenciasDeInfraestructura(Map<String, Object Function()> deps)
      : super(deps);

  IAdaptadorDeBaseDeDatos database() {
    return obtenerDependencia<IAdaptadorDeBaseDeDatos>();
  }

  ILogger logger() {
    return obtenerDependencia<ILogger>();
  }

  ISync sync() {
    return obtenerDependencia<ISync>();
  }

  IAdaptadorDeTelemetria telemetria() {
    return obtenerDependencia<IAdaptadorDeTelemetria>();
  }

  IAdaptadorDeDispositivo dispositivo() {
    return obtenerDependencia<IAdaptadorDeDispositivo>();
  }
}

class DependenciasDeVentas extends _RegistroDeDependencias {
  DependenciasDeVentas(Map<String, Object Function()> deps) : super(deps);

  IRepositorioDeVentas repositorioVentas() {
    return obtenerDependencia<IRepositorioDeVentas>();
  }

  IRepositorioArticulos repositorioArticulos() {
    return obtenerDependencia<IRepositorioArticulos>();
  }

  IAdaptadorDeConfigLocalDeVentas adaptadorDeConfigLocalDeVentas() {
    return obtenerDependencia<IAdaptadorDeConfigLocalDeVentas>();
  }
}

class Dependencias {
  static final _deps = <String, Object Function()>{};

  static final DependenciasDeInfraestructura infra =
      DependenciasDeInfraestructura(_deps);
  static final DependenciasDeVentas ventas = DependenciasDeVentas(_deps);

  static registrar(String interface, Object Function() builder) {
    _deps.putIfAbsent(interface, () => builder);
  }
}
