import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class EliminarProductoRequest {
  late UID uidProducto;
}

class EliminarProducto extends Usecase<void> {
  var req = EliminarProductoRequest();

  final IRepositorioProductos _productos;

  EliminarProducto(IRepositorioProductos productos)
      : _productos = productos,
        super(productos) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _productos.eliminar(req.uidProducto);
  }
}
