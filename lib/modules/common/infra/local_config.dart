import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalConfig {
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

    switch (value.runtimeType) {
      case int:
        await prefs?.setInt(name, value as int);
        break;
      case double:
        await prefs?.setDouble(name, value as double);
        break;
      case bool:
        await prefs?.setBool(name, value as bool);
        break;
      case String:
        await prefs?.setString(name, value as String);
        break;
      default:
        throw UnimplementedError(
            'No implementado: ${value.runtimeType.toString()}');
    }
  }

  Future<T> readValue<T>(String name) async {
    prefs ??= await SharedPreferences.getInstance();

    T res;

    if (T is bool?) {
      res = prefs?.getBool(name) as T;
    } else if (T is String?) {
      res = prefs?.getString(name) as T;
    } else if (T is int?) {
      res = prefs?.getInt(name) as T;
    } else if (T is double?) {
      res = prefs?.getDouble(name) as T;
    } else {
      throw UnimplementedError('No implementado: ${T.toString()}');
    }

    return res;
  }

  Future<void> init() async {}
}
