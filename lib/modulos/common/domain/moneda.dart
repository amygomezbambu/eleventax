import 'dart:math';

class Moneda {
  var _parteEntera = 0;
  var _parteDecimal = 0;
  var _montoInt = 0;

  final _digitosDecimales = 6;

  int get digitosDecimales => _digitosDecimales;

  /// Crear un objeto Moneda
  ///
  /// [monto] puede ser un double o un int, si es un int se tomaran los ultimos
  /// ***digitos decimales*** como la parte decimal, ejemplo:
  ///
  /// ```dart
  /// var moneda = Moneda(100500000); //moneda.digitosDecimales = 6;
  /// print(moneda.toString()); // 100.500000
  ///
  /// moneda = Moneda(100.50);
  /// print(moneda.toInt()); // 100500000;
  /// ```
  Moneda(Object monto) {
    if (monto is double) {
      _parteEntera = monto.truncate();
      _parteDecimal =
          ((monto - _parteEntera) * (pow(10, _digitosDecimales))).round();

      _montoInt =
          int.parse((_parteEntera.toString() + _parteDecimal.toString()));
    }

    if (monto is int) {
      _montoInt = monto;
    }
  }

  int toInt() {
    return _montoInt;
  }

  @override
  String toString() {
    return '\$ $_parteEntera.$_parteDecimal';
  }
}
