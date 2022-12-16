// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:meta/meta.dart';

import 'package:eleventa/modulos/common/exception/excepciones.dart';

///Campo nombre de una entidad.
///
class NombreValueObject {
  @protected
  late String value_;

  late int _longitudMaxima;

  String get value => value_;

  NombreValueObject({required String nombre, int longitudMaxima = 100}) {
    value_ = _sanitizar(nombre);
    _longitudMaxima = longitudMaxima;
    _validar(value_);
  }

  @override
  bool operator ==(Object other) {
    return (other as NombreValueObject).value == value;
  }

  @override
  int get hashCode => value.hashCode ^ value.hashCode;

  String _sanitizar(String nombre) {
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

  @override
  String toString() =>
      'NombreValueObject(value: $value_, longitudMaxima: $_longitudMaxima)';
}
