import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';

class ModificarCategoriaRequest {
  late Categoria categoria;
}

class ModificarCategoria extends Usecase<void> {
  var req = ModificarCategoriaRequest();
  final IRepositorioProductos _repoProductos;
  final IRepositorioConsultaProductos _consultas;

  ModificarCategoria(
      IRepositorioProductos repo, IRepositorioConsultaProductos consultas)
      : _repoProductos = repo,
        _consultas = consultas,
        super(repo) {
    operation = _operation;
  }

  Future<void> _operation() async {
    if (await _consultas.existeCategoria(nombre: req.categoria.nombre)) {
      throw ValidationEx(
        tipo: TipoValidationEx.entidadNoExiste,
        mensaje: 'El nombre de categoria ya existe: ${req.categoria.nombre}',
      );
    }

    await _repoProductos.modificarCategoria(req.categoria);
  }
}
