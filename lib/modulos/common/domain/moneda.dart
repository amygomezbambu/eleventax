import 'dart:math';

import 'package:eleventa/modulos/common/exception/excepciones.dart';

class Moneda {
  var _parteEntera = 0;
  var _parteDecimal = 0;
  var _montoInt = 0;

  final _digitosDecimales = 6;

  int get digitosDecimales => _digitosDecimales;

  /// Crear un objeto Moneda desde un double
  ///
  /// [monto] debe ser un double
  ///
  /// ```dart
  /// var moneda = Moneda(100.50);
  /// print(moneda.toInt()); // 100500000;
  /// ```
  Moneda.fromDouble(double monto) {
    _fromDouble(monto);
  }

  /// Crear un objeto Moneda desde una cadena
  ///
  /// [monto] debe ser una cadena que pueda ser parseada a double
  ///
  /// ```dart
  /// var moneda = Moneda('100.50');
  /// print(moneda.toInt()); // 100500000;
  /// ```
  Moneda.fromDoubleString(String monto) {
    var montoConvertido = double.tryParse(monto);

    if (montoConvertido == null) {
      throw EleventaEx(
          message: 'La cadena no es un numero decimal valido: $monto');
    }

    _fromDouble(montoConvertido);
  }

  /// Crear un objeto Moneda desde un int
  ///
  /// [monto] debe ser un entero
  ///
  /// ```dart
  /// var moneda = Moneda(100500000); //moneda.digitosDecimales = 6;
  /// print(moneda.toString()); // 100.500000
  /// ```
  Moneda.fromInt(int monto) {
    _montoInt = monto;
  }

  int toInt() {
    return _montoInt;
  }

  @override
  String toString() {
    return '\$ $_parteEntera.$_parteDecimal';
  }

  void _fromDouble(double monto) {
    _parteEntera = monto.truncate();
    _parteDecimal =
        ((monto - _parteEntera) * (pow(10, _digitosDecimales))).round();

    _montoInt = int.parse((_parteEntera.toString() + _parteDecimal.toString()));
  }
}
