import 'package:eleventa/modulos/common/domain/nombre_value_object.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

class NombreCategoria extends NombreValueObject {
  static const _sinCategoria = 'Sin Categoría';

  NombreCategoria(String nombre) : super(nombre: nombre, longitudMaxima: 130) {
    _validar(nombre);
  }

  NombreCategoria.sinCategoria() : super(nombre: _sinCategoria);

  void _validar(String value) {
    final dato =
        Utils.string.removerEspacios(value.toLowerCase()).replaceAll('í', 'i');

    final nombreReservado = Utils.string
        .removerEspacios(_sinCategoria.toLowerCase())
        .replaceAll('í', 'i');

    if (dato == nombreReservado) {
      throw (DomainEx('Nombre categoría no es válido'));
    }
  }
}
