import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class CrearProductoRequest {
  late Producto producto;
}

class CrearProducto extends Usecase<void> {
  var req = CrearProductoRequest();
  final IRepositorioProductos _productos;

  CrearProducto(IRepositorioProductos productos)
      : _productos = productos,
        super(productos) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _productos.agregar(req.producto);
  }
}
