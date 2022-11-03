import 'package:eleventa/modulos/common/app/interface/repositorio.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';

abstract class IRepositorioProductos extends IRepositorio<Producto> {
  Future<Producto?> obtenerPorCodigo(String codigo);
  Future<void> guardarConfigCompartida(ConfigCompartidaDeProductos config);
  Future<ConfigCompartidaDeProductos> obtenerConfigCompartida();
}
