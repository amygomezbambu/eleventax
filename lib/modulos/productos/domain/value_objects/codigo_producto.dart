import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

class CodigoProducto {
  //Constantes
  final _codigoReservado = '0';
  final _longitudMaxima = 20;
  //TODO: revisar la correcta validacion del codigo y qué caracteres
  final _regex = RegExp(r'[a-zA-Z0-9_\-=@,\.;]+$');

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
      throw DomainEx('El código no puede estar vacío');
    }

    if (codigo.length > _longitudMaxima) {
      throw DomainEx('El código no puede tener mas de $_longitudMaxima letras');
    }

    if (codigo == _codigoReservado) {
      throw DomainEx('El codigo $_codigoReservado no es un código valido');
    }

    if (!_regex.hasMatch(codigo)) {
      throw DomainEx('El codigo contiene caracteres invalidos');
    }
  }
}
