import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

class Categoria extends Entidad {
  final String _nombre;

  String get nombre => _nombre;

  Categoria.crear({required String nombre})
      : _nombre = nombre,
        super.crear();

  Categoria.cargar({
    required UID uid,
    required String nombre,
  })  : _nombre = nombre,
        super.cargar(uid);
}
