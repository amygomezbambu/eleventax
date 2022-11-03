// ignore_for_file: unnecessary_getters_setters
import 'package:eleventa/modulos/common/infra/config_local.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class ConfigCompartidaDeProductos {
  UID _uid = UID();
  UID get uid => _uid;
  var permitirPrecioCompraCero = true;

  ConfigCompartidaDeProductos();

  ConfigCompartidaDeProductos.cargar(
      {required UID uid, required this.permitirPrecioCompraCero})
      : _uid = uid;
}

class ConfigLocalDeProductos extends ConfigLocal {}

class ConfigProductos {
  final IRepositorioProductos _repo;

  ConfigCompartidaDeProductos compartida = ConfigCompartidaDeProductos();
  ConfigLocalDeProductos local = ConfigLocalDeProductos();

  ConfigProductos(this._repo);

  Future<void> leer() async {
    //await local._leer();
    compartida = await _repo.obtenerConfigCompartida();
  }

  Future<void> guardar() async {
    //await local._guardar();
    await _repo.guardarConfigCompartida(compartida);
  }
}
