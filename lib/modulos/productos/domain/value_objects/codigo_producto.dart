// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

class CodigoProducto {
  //Constantes
  final _codigoReservado = '0';
  final _longitudMaxima = 20;
  //final _regex = RegExp(r'[À-ÿa-zA-Z0-9_\-=@,\.\+;*\$&:"\/\s]+$');

  late String _codigo;

  String get value => _codigo;

  CodigoProducto(String codigo) {
    _codigo = _sanitizar(codigo);
    _validar(_codigo);
  }

  String _sanitizar(String codigo) {
    codigo = Utils.string.limpiarCaracteresInvisibles(codigo);
    codigo = codigo.trim();
    codigo = codigo.toUpperCase();

    return codigo;
  }

  void _validar(String codigo) {
    if (codigo.isEmpty) {
      throw ValidationEx(
          tipo: TipoValidationEx.valorVacio,
          mensaje: 'El código no puede estar vacío');
    }

    if (codigo.length > _longitudMaxima) {
      throw ValidationEx(
          tipo: TipoValidationEx.longitudInvalida,
          mensaje: 'El código no puede tener mas de $_longitudMaxima letras');
    }

    if (codigo == _codigoReservado) {
      throw ValidationEx(
          tipo: TipoValidationEx.valorReservado,
          mensaje: 'El codigo $_codigoReservado no es un código valido');
    }
  }

  @override
  String toString() => 'CodigoProducto(codigo: $_codigo)';
}
