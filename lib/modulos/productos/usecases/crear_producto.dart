import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class CrearProductoRequest {
  late Producto producto;
}

class CrearProducto extends Usecase<void> {
  var req = CrearProductoRequest();
  final IRepositorioProductos _productos;
  final IRepositorioConsultaProductos _consultas;

  CrearProducto(
      IRepositorioProductos productos, IRepositorioConsultaProductos consultas)
      : _productos = productos,
        _consultas = consultas,
        super(productos) {
    operation = _operation;
  }

  Future<void> _operation() async {
    if (await _consultas.existeProducto(req.producto.codigo)) {
      throw ValidationEx(
        tipo: TipoValidationEx.entidadYaExiste,
        mensaje: 'El código de producto ya existe: ${req.producto.codigo}',
      );
    }

    await _productos.agregar(req.producto);
  }
}
