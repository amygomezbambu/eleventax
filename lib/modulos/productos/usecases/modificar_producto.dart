import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class ModificarProductoReq {
  late Producto producto;
}

class ModificarProducto extends Usecase<void> {
  var req = ModificarProductoReq();
  final IRepositorioProductos _productos;

  ModificarProducto(this._productos) : super(_productos) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _productos.modificar(req.producto);
  }
}
