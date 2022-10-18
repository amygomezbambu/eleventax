import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/productos/app/dto/producto_dto.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/app/mapper/producto_mapper.dart';

// class ObtenerProductos extends Usecase<List<ProductoDTO>> {
//   final IRepositorioArticulos _repo;

//   ObtenerProductos(this._repo) : super(_repo) {
//     operation = _operation;
//   }

//   Future<List<ProductoDTO>> _operation() async {
//     var productos = (await _repo.obtenerTodos())
//         .map((producto) => ProductoMapper.domainAData(producto))
//         .toList();

//     return productos;
//   }
// }
