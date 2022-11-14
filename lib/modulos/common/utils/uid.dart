import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:xid/xid.dart';

class UID {
  late String _identifier;
  static const _invalidIdentifier = '0';

  /// Crear un nuevo UID
  UID() {
    _identifier = Xid().toString();
  }

  ///Crea un UID a partir de una cadena
  ///
  /// Si el parametro [uidString] es valido entonces se utiliza para crear
  /// un nuevo UID, si es invalido se lanza [EleventaEx].
  UID.fromString(String uidString) {
    if (isValid(uidString)) {
      _identifier = uidString;
    } else {
      throw EleventaEx(message: 'El identificador es invalido');
    }
  }

  /// Crear un uid invalido
  UID.invalid() : _identifier = _invalidIdentifier;

  /// Determina si la cadena proporcionada [uidString] representa un UID valido
  static bool isValid(String uidString) {
    try {
      Xid.fromString(uidString);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is UID && (toString() == other.toString());
  }

  @override
  String toString() {
    return _identifier.toString();
  }
}
