import 'package:eleventa/modulos/productos/domain/entity/producto.dart';
import 'package:eleventa/modulos/common/app/interface/repositorio.dart';

abstract class IRepositorioArticulos extends IRepositorio<Producto> {
  Future<Producto?> obtenerPorSKU(String sku);
}
