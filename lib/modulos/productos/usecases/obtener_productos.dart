import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class ObtenerProductos extends Usecase<List<Producto>> {
  final IRepositorioProductos _productos;

  ObtenerProductos(this._productos) : super(_productos) {
    operation = _operation;
  }

  Future<List<Producto>> _operation() async {
    var productos = await _productos.obtenerTodos();

    return productos;
  }
}
