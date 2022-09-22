import 'package:xid/xid.dart';

class UID {
  String _identifier = '';

  UID([String uid = '']) {
    if (uid == '') {
      _generate();
    } else {
      if (isValid(uid)) {
        _identifier = uid;
      } else {
        throw Exception('El uid proporcionado es invalido: $uid');
      }
    }
  }

  static bool isValid(String uid) {
    try {
      Xid.fromString(uid);

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
    return _identifier;
  }

  /// Genera una cadena que representa un identificador unico
  void _generate() {
    var uid = Xid();
    _identifier = uid.toString();
  }
}
