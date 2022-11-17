import 'dart:math';

import 'package:eleventa/modulos/common/exception/excepciones.dart';

typedef MonedaInt = int;

class Moneda {
  var _parteEntera = 0;
  var _parteDecimal = 0;
  MonedaInt _montoInterno = 0;

  final _digitosDecimales = 6;
  final _numeroDigitosAMostrar = 2;

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
  /// [monto] debe ser un entero
  ///
  /// ```dart
  /// var moneda = Moneda(100500000); //moneda.digitosDecimales = 6;
  /// print(moneda.toString()); // 100.500000
  /// ```
  Moneda.fromMonedaInt(MonedaInt monto) {
    _montoInterno = monto;

    var montoString = monto.toString();

    _parteEntera = int.parse(
      montoString.substring(0, montoString.length - _digitosDecimales),
    );

    _parteDecimal = int.parse(
      montoString.substring(
          montoString.length - _digitosDecimales, montoString.length),
    );
  }

  MonedaInt toMonedaInt() {
    return _montoInterno;
  }

  void _fromDouble(double monto) {
    _parteEntera = monto.truncate();

    _parteDecimal =
        ((monto - _parteEntera) * (pow(10, _digitosDecimales))).round();

    _montoInterno = int.parse((_parteEntera.toString() +
        _parteDecimal.toString().padRight(_digitosDecimales, '0')));
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
    //12 en la parte entera -> 999 999 999 999
    if (monto is double) {
      if (monto.truncate().toString().length > 12) {
        throw EleventaEx(message: 'El valor máximo es 999 999 999 999');
      }
    } else if (monto is String) {
      _fromString(monto);
      if (_parteEntera > 999999999999) {
        throw EleventaEx(message: 'El valor máximo es 999 999 999 999');
      }
    } else if (monto is int) {
      if (monto > 999999999999) {
        throw EleventaEx(message: 'El valor máximo es 999 999 999 999');
      }
      _fromDouble(monto.toDouble());
    } else {
      throw EleventaEx(message: 'Moneda solo acepta un double, int o String.');
    }
  }

  //TODO: checar si es posible una mejorar manera ya que el parse puede hacer redondeos
  double toDouble() {
    var valor = double.parse('$_parteEntera.$_parteDecimal');

    return valor;
  }

  @override
  String toString() {
    var valorCompleto = double.parse('$_parteEntera.$_parteDecimal');

    return '\$ ${valorCompleto.toStringAsFixed(_numeroDigitosAMostrar)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Moneda &&
        other._parteEntera == _parteEntera &&
        other._parteDecimal == _parteDecimal &&
        other._montoInterno == _montoInterno;
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
  int get hashCode =>
      _parteEntera.hashCode ^ _parteDecimal.hashCode ^ _montoInterno.hashCode;
}
