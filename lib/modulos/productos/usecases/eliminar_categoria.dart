import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class EliminarCategoriaRequest {
  late UID uidCategoria;
}

class EliminarCategoria extends Usecase<void> {
  final req = EliminarCategoriaRequest();
  final IRepositorioProductos _repoProductos;

  EliminarCategoria(IRepositorioProductos productos)
      : _repoProductos = productos,
        super(productos) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _repoProductos.eliminarCategoria(req.uidCategoria);
  }
}
