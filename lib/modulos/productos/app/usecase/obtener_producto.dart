import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/app/dto/producto_dto.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/domain/entity/producto.dart';
import 'package:eleventa/modulos/productos/app/mapper/producto_mapper.dart';

class ObtenerProductoReq {
  String sku = '';
}

class ObtenerProducto extends Usecase<ProductoDTO> {
  final IRepositorioArticulos _repo;
  final req = ObtenerProductoReq();

  ObtenerProducto(this._repo) : super(_repo) {
    operation = _operation;
  }

  Future<ProductoDTO> _operation() async {
    Producto? producto = await _repo.obtenerPorSKU(req.sku);

    if (producto == null) {
      final message = 'El Codigo de producto ${req.sku} no se encontró';

      logger.error(ex: AppEx(message: message));

      throw AppEx(message: message);
    }

    return ProductoMapper.domainAData(producto);
  }
}
