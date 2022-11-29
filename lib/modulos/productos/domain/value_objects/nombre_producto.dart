import 'package:eleventa/modulos/common/domain/nombre_value_object.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

class NombreProducto extends NombreValueObject {
  NombreProducto(String nombre) : super(nombre: nombre, longitudMaxima: 130) {
    valor = _sanitizar(nombre);
  }

  String _sanitizar(String nombre) {
    nombre = Utils.string.limpiarCaracteresInvisibles(nombre);
    nombre = Utils.string.removerExcesoDeEspacios(nombre);
    nombre = Utils.string.capitalizar(nombre);

    return nombre;
  }
}
