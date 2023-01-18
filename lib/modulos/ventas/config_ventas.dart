// ignore_for_file: unnecessary_getters_setters
import 'package:eleventa/modulos/common/infra/config_local.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

class ConfigCompartidaDeVentas {
  UID _uid = UID();
  var _permitirProductoComun = true;
  var _permitirCostoZero = true;

  UID get uid => _uid;
  bool get permitirProductoComun => _permitirProductoComun;
  bool get permitirCostoZero => _permitirCostoZero;

  set permitirProductoComun(bool value) {
    _permitirProductoComun = value;
  }

  ConfigCompartidaDeVentas();

  ConfigCompartidaDeVentas.cargar(
      {required UID uid,
      required bool permitirProductoComun,
      required bool permitirCostoZero})
      : _uid = uid,
        _permitirProductoComun = permitirProductoComun,
        _permitirCostoZero = permitirCostoZero;
}

class ConfigLocalDeVentas extends ConfigLocal {
  var _permitirDescuentos = true;

  bool get permitirDescuentos => _permitirDescuentos;

  set permitirDescuentos(bool value) {
    _permitirDescuentos = value;
  }

  ConfigLocalDeVentas();

  // Future<void> _leer() async {
  //   _permitirDescuentos =
  //       (await readValue<bool>('permitirDescuentos')) ?? _permitirDescuentos;
  // }

  // Future<void> _guardar() async {
  //   await saveValue('permitirDescuentos', _permitirDescuentos);
  // }
}

// class ConfigVentas {
//   final IRepositorioDeVentas _repo;

//   ConfigCompartidaDeVentas compartida = ConfigCompartidaDeVentas();
//   ConfigLocalDeVentas local = ConfigLocalDeVentas();

//   ConfigVentas(this._repo);

//   Future<void> leer() async {
//     await local._leer();
//     compartida = await _repo.obtenerConfigCompartida();
//   }

//   Future<void> guardar() async {
//     await local._guardar();
//     await _repo.guardarConfigCompartida(compartida);
//   }
// }
