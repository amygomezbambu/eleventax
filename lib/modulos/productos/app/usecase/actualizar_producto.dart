import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/app/dto/producto_dto.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/domain/entity/producto.dart';

class ActualizarProductoReq {
  ProductoDTO producto = ProductoDTO();
}

class ActualizarProducto extends Usecase<void> {
  var req = ActualizarProductoReq();
  final IRepositorioArticulos _repo;

  ActualizarProducto(this._repo) : super(_repo) {
    operation = _operation;
  }

  Future<void> _operation() async {
    // var item = Producto.cargar(
    //   UID(req.producto.uid),
    //   req.producto.sku,
    //   req.producto.descripcion,
    //   req.producto.precio,
    // );

    // await _repo.actualizar(item);
  }
}
