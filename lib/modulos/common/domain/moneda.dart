import 'dart:math';

import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';

typedef MonedaInt = int;

class Moneda {
  MonedaInt _montoInterno = 0;

  static const _digitosDecimales = 6;

  MonedaInt get montoInterno => _montoInterno;

  /// Crear un objeto Moneda desde un monto
  ///
  /// [monto] debe ser un String, int o double
  ///
  /// ```dart
  /// var moneda = Moneda(10.50); //moneda.digitosDecimales = 6;
  /// print(moneda.toString()); // 100.500000
  /// ```
  Moneda(dynamic monto) {
    _validar(monto);

    if (monto is double) {
      _fromDouble(monto);
    } else if (monto is String) {
      _fromString(monto);
    } else if (monto is int) {
      _fromDouble(monto.toDouble());
    } else {
      throw EleventaEx(message: 'Moneda solo acepta un double, int o String.');
    }
  }

  /// Crear un objeto Moneda desde un int
  ///
  /// [monto] debe ser un entero positivo
  ///
  /// ```dart
  /// var moneda = Moneda(100500000); //moneda.digitosDecimales = 6;
  /// print(moneda.toString()); // 100.500000
  /// ```
  Moneda.fromMonedaInt(MonedaInt monto) {
    _montoInterno = monto;
  }

  MonedaInt toMonedaInt() {
    return _montoInterno;
  }

  void _fromDouble(double monto) {
    _montoInterno = (monto * pow(10, _digitosDecimales)).round();
  }

  /// Crear un objeto Moneda desde una cadena
  ///
  /// [monto] debe ser una cadena que pueda ser parseada a double
  ///
  /// ```dart
  /// var moneda = Moneda('100.50');
  /// print(moneda.toInt()); // 100500000;
  /// ```
  void _fromString(String monto) {
    var montoConvertido = double.tryParse(monto);

    if (montoConvertido == null) {
      throw EleventaEx(
          message: 'La cadena no es un numero decimal valido: $monto');
    }

    _fromDouble(montoConvertido);
  }

  void _validar(dynamic monto) {
    if (monto is num && monto < 0) {
      throw ValidationEx(mensaje: 'El monto debe ser positivo');
    }

    if (monto is String && monto.contains('-')) {
      throw ValidationEx(mensaje: 'El monto debe ser positivo');
    }

    if (monto is double) {
      if (monto.truncate().toString().length > 12) {
        throw ValidationEx(mensaje: 'El valor máximo es 999 999 999 999');
      }
    } else if (monto is String) {
      _fromString(monto);
      if (_montoInterno.truncate() > 999999999999) {
        throw ValidationEx(mensaje: 'El valor máximo es 999 999 999 999');
      }
    } else if (monto is int) {
      if (monto > 999999999999) {
        throw ValidationEx(mensaje: 'El valor máximo es 999 999 999 999');
      }
      _fromDouble(monto.toDouble());
    } else {
      throw ValidationEx(
          mensaje: 'Moneda solo acepta un double, int o String.');
    }
  }

  double toDouble() {
    return _montoInterno / (pow(10, _digitosDecimales));
  }

  @override
  String toString() {
    return '\$${toDouble().toStringAsFixed(appConfig.decimalesAMostrar)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Moneda && other._montoInterno == _montoInterno;
  }

  Moneda operator +(Moneda v) =>
      Moneda.fromMonedaInt(montoInterno + v._montoInterno);
  Moneda operator -(Moneda v) =>
      Moneda.fromMonedaInt(montoInterno - v._montoInterno);

  bool operator <=(Moneda other) => _montoInterno <= other.montoInterno;
  bool operator <(Moneda other) => _montoInterno < other.montoInterno;
  bool operator >(Moneda other) => _montoInterno > other.montoInterno;
  bool operator >=(Moneda other) => _montoInterno >= other.montoInterno;

  @override
  int get hashCode => _montoInterno.hashCode;
}
