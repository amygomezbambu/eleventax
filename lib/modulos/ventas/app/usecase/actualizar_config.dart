import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/ventas/app/interface/adaptador_de_config_local.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';

class ActualizarConfigReq {
  var config = ConfigVentas();
}

class ActualizarConfig extends Usecase<void> {
  final req = ActualizarConfigReq();
  final IRepositorioDeVentas _repo;
  final IAdaptadorDeConfigLocalDeVentas _configLocal;

  ActualizarConfig(this._repo, this._configLocal) : super(_repo) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _repo.guardarConfigCompartida(req.config.compartida);
    await _configLocal.guardar(req.config.local);
  }
}
