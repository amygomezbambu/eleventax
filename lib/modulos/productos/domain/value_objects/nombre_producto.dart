import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

class NombreProducto {
  final _longitudMaxima = 130;
  late String _nombre;
  String get value => _nombre;

  NombreProducto(String nombre) {
    _nombre = _sanitizar(nombre);
    _validar(_nombre);
  }

  String _sanitizar(String nombre) {
    nombre = Utils.string.limpiarCaracteresInvisibles(nombre);
    nombre = Utils.string.removerExcesoDeEspacios(nombre);
    nombre = Utils.string.capitalizar(nombre);

    return nombre.trim();
  }

  void _validar(String value) {
    if (value.isEmpty) {
      throw DomainEx('El nombre del producto no puede estar vacío');
    }

    if (value.length > _longitudMaxima) {
      throw DomainEx('El código no puede tener mas de $_longitudMaxima letras');
    }
  }
}
