import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class ActualizarProductoReq {
  late Producto producto;
}

class ActualizarProducto extends Usecase<void> {
  var req = ActualizarProductoReq();
  final IRepositorioProductos _productos;

  ActualizarProducto(this._productos) : super(_productos) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _productos.actualizar(req.producto);
  }
}
