import 'package:xid/xid.dart';

class UID {
  /// Genera una cadena que representa un identificador unico
  String generate() {
    var result = Xid();
    return result.toString();
  }
}

class Utils {
  static final uid = UID();
}
