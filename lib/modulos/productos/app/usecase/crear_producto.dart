import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/domain/entity/producto.dart';

class CrearProductoReq {
  String sku = '';
  String descripcion = '';
  double precio = 0.00;
}

class CrearProducto extends Usecase<UID> {
  final IRepositorioArticulos _repo;
  CrearProductoReq req = CrearProductoReq();

  CrearProducto(this._repo) : super(_repo) {
    operation = _operation;
  }

  Future<UID> _operation() async {
    Producto producto = Producto.crear(
      sku: req.sku,
      descripcion: req.descripcion,
      precio: req.precio,
    );

    await _repo.agregar(producto);

    return producto.uid;
  }
}
