import 'package:shared_preferences/shared_preferences.dart';

abstract class ConfigLocal {
  SharedPreferences? prefs;

  Future<void> saveValues(String name, List<String> values) async {
    prefs ??= await SharedPreferences.getInstance();

    await prefs?.setStringList(name, values);
  }

  /// Guarda un valor de una configuración en el almacenamiento local del dispositivo
  /// usando el almacenaje del S.O.
  /// [name] es el nombre del parámetro y [value] puede tomar
  /// un int, double, bool o String.
  Future<void> saveValue(String name, Object value) async {
    prefs ??= await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs?.setBool(name, value);
    } else if (value is int) {
      await prefs?.setInt(name, value);
    } else if (value is double) {
      await prefs?.setDouble(name, value);
    } else if (value is String) {
      await prefs?.setString(name, value);
    } else {
      throw UnimplementedError('No implementado: ${(value).toString()}');
    }
  }

  Future<T?> readValue<T>(String name) async {
    prefs ??= await SharedPreferences.getInstance();

    if (T == bool) {
      return (prefs?.getBool(name) != null) ? prefs?.getBool(name) as T : null;
    } else if (T == String) {
      return (prefs?.getString(name) != null)
          ? prefs?.getString(name) as T
          : null;
    } else if (T == int) {
      return (prefs?.getInt(name) != null) ? prefs?.getInt(name) as T : null;
    } else if (T == double) {
      return (prefs?.getDouble(name) != null)
          ? prefs?.getDouble(name) as T
          : null;
    } else {
      throw UnimplementedError('No implementado: ${T.toString()}');
    }
  }
}
