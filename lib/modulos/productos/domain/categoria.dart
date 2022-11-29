import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';

class Categoria extends Entidad {
  final NombreCategoria _nombre;

  String get nombre => _nombre.value;

  Categoria.crear({required NombreCategoria nombre})
      : _nombre = nombre,
        super.crear();

  Categoria.cargar({
    required UID uid,
    required NombreCategoria nombre,
  })  : _nombre = nombre,
        super.cargar(uid);
}
