import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:meta/meta.dart';

///Campo nombre de una entidad.
///
class NombreValueObject {
  @protected
  late String valor;
  late int _longitudMaxima;

  String get value => valor;

  NombreValueObject({required String nombre, int longitudMaxima = 100}) {
    valor = _sanitizar(nombre);
    _longitudMaxima = longitudMaxima;
    _validar(valor);
  }

  @protected
  void lanzarExcepcion({required String mensaje}) {
    throw DomainEx(mensaje);
  }

  @override
  bool operator ==(Object other) {
    return (other as NombreValueObject).value == value;
  }

  @override
  int get hashCode => value.hashCode ^ value.hashCode;

  String _sanitizar(String nombre) {
    //nombre = Utils.string.removerExcesoDeEspacios(nombre);
    return nombre.trim();
  }

  void _validar(String value) {
    if (value.isEmpty) {
      throw DomainEx('El valor no puede estar vacío');
    }

    if (value.length > _longitudMaxima) {
      throw DomainEx(
          'El valor no puede tener más de $_longitudMaxima caracteres');
    }
  }
}
