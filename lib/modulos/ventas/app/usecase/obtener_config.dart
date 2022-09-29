import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/ventas/app/interface/adaptador_de_config_local.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';

class ObtenerConfig extends Usecase<ConfigVentas> {
  final IRepositorioDeVentas _repo;
  final IAdaptadorDeConfigLocalDeVentas _configLocal;

  ObtenerConfig(this._repo, this._configLocal) : super(_repo) {
    operation = _operation;
  }

  Future<ConfigVentas> _operation() async {
    var config = ConfigVentas();

    config.compartida = await _repo.obtenerConfigCompartida();
    config.local = await _configLocal.leer();

    return config;
  }
}
