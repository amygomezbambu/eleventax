import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class ObtenerProductoReq {
  late UID uidProducto;
}

class ObtenerProducto extends Usecase<Producto> {
  final IRepositorioProductos _productos;
  final req = ObtenerProductoReq();

  ObtenerProducto(this._productos) : super(_productos) {
    operation = _operation;
  }

  Future<Producto> _operation() async {
    Producto? producto = await _productos.obtener(req.uidProducto);

    if (producto == null) {
      final message = 'El Codigo de producto ${req.uidProducto} no se encontró';

      logger.error(ex: AppEx(message: message));

      throw AppEx(message: message);
    }

    return producto;
  }
}
