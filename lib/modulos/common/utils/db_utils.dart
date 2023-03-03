class DBUtils {
  bool intToBool(int value) {
    return (value == 0) ? false : true;
  }

  int boolToInt(bool value) {
    return (value) ? 1 : 0;
  }

  /// Retorna el valor [value] si es diferente de null, de lo contrario retorna
  /// una cadena vacía.
  String valorOCadenaVacia(Object? value) {
    return (value == null) ? '' : value as String;
  }
}
