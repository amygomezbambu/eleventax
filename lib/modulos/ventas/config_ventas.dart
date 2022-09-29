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

  set permitirDescuentos(bool value) {
    _permitirDescuentos = value;
  }

  bool get permitirDescuentos => _permitirDescuentos;

  ConfigLocalDeVentas();

  Map<String, Object> toMap() {
    return {'permitirDescuentos': _permitirDescuentos};
  }
}

class ConfigVentas {
  ConfigCompartidaDeVentas compartida = ConfigCompartidaDeVentas();
  ConfigLocalDeVentas local = ConfigLocalDeVentas();
}
