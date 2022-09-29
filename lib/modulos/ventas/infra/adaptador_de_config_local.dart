import 'package:eleventa/modulos/common/infra/config_local.dart';
import 'package:eleventa/modulos/ventas/app/interface/adaptador_de_config_local.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';

class AdaptadorDeConfigLocalDeVentas extends ConfigLocal
    implements IAdaptadorDeConfigLocalDeVentas {
  @override
  Future<ConfigLocalDeVentas> leer() async {
    var configLocal = ConfigLocalDeVentas();

    configLocal.permitirDescuentos =
        (await readValue<bool>('permitirDescuentos')) ??
            configLocal.permitirDescuentos;

    return configLocal;
  }

  @override
  Future<void> guardar(ConfigLocalDeVentas config) async {
    var values = config.toMap();

    for (var key in values.keys) {
      await saveValue(key, values[key]!);
    }
  }
}
