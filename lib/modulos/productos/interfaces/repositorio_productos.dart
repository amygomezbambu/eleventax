import 'package:eleventa/modulos/common/app/interface/repositorio.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';

abstract class IRepositorioProductos extends IRepositorio<Producto> {
  Future<void> guardarConfigCompartida(ConfigCompartidaDeProductos config);
  Future<ConfigCompartidaDeProductos> obtenerConfigCompartida();
  Future<Map<String, Object>> obtenerNombreYCodigo(UID uid);
  Future<void> agregarCategoria(Categoria categoria);
  Future<void> eliminarCategoria(UID uid);
}
