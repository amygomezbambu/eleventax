import 'dart:math';

import 'package:eleventa/globals.dart';
import 'package:decimal/decimal.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';

typedef MonedaInt = int;

class Moneda {
  MonedaInt _montoInterno = 0;

  static const _digitosDecimales = 6;
  static const _digitosCobrables = 2;

  MonedaInt get montoInterno => _montoInterno;

  /// Regresa el monto como un importe cobrable a 2 decimales
  /// con redondeo aritmetico
  Moneda get importeCobrable => redondearADecimales(_digitosCobrables);

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
  Moneda.deserialize(MonedaInt monto) {
    _montoInterno = monto;
  }

  MonedaInt serialize() {
    return _montoInterno;
  }

  Moneda redondearADecimales(int decimales) {
    return Moneda(
      Decimal.parse(toDouble().toString()).toStringAsFixed(decimales),
    );
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
      throw ValidationEx(
        mensaje: 'La cadena no es un numero decimal valido: $monto',
        tipo: TipoValidationEx.errorDeValidacion,
      );
    }

    _fromDouble(montoConvertido);
  }

  //TODO: crear tipos especificos para cada error de moneda
  void _validar(dynamic monto) {
    const maxInt = 999999999999;

    if (monto is num && monto < 0) {
      throw ValidationEx(
        mensaje: 'El monto debe ser positivo',
        tipo: TipoValidationEx.valorNegativo,
      );
    }

    if (monto is String && monto.contains('-')) {
      throw ValidationEx(
          mensaje: 'El monto debe ser positivo',
          tipo: TipoValidationEx.valorNegativo);
    }

    if (monto is double) {
      if (monto.truncate().toString().length > 12) {
        throw ValidationEx(
            mensaje: 'El valor máximo es 999 999 999 999',
            tipo: TipoValidationEx.errorDeValidacion);
      }
    } else if (monto is String) {
      _fromString(monto);
      if (toDouble().truncate() > maxInt) {
        throw ValidationEx(
            mensaje: 'El valor máximo es 999 999 999 999',
            tipo: TipoValidationEx.errorDeValidacion);
      }
    } else if (monto is int) {
      if (monto > maxInt) {
        throw ValidationEx(
            mensaje: 'El valor máximo es 999 999 999 999',
            tipo: TipoValidationEx.errorDeValidacion);
      }
      _fromDouble(monto.toDouble());
    } else {
      throw ValidationEx(
          mensaje: 'Moneda solo acepta un double, int o String.',
          tipo: TipoValidationEx.argumentoInvalido);
    }
  }

  double toDouble() {
    return _montoInterno / (pow(10, _digitosDecimales));
  }

  @override
  String toString() {
    var valor = Decimal.parse(toDouble().toString());
    return valor.toStringAsFixed(appConfig.decimalesAMostrar);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Moneda && other._montoInterno == _montoInterno;
  }

  Moneda operator +(Moneda v) =>
      Moneda.deserialize(montoInterno + v._montoInterno);
  Moneda operator -(Moneda v) =>
      Moneda.deserialize(montoInterno - v._montoInterno);
  Moneda operator *(Moneda v) =>
      Moneda.deserialize(montoInterno * v._montoInterno);
  Moneda operator /(Moneda v) => Moneda(montoInterno / v._montoInterno);

  bool operator <=(Moneda other) => _montoInterno <= other.montoInterno;

  bool operator <(Moneda other) => _montoInterno < other.montoInterno;
  bool operator >(Moneda other) => _montoInterno > other.montoInterno;
  bool operator >=(Moneda other) => _montoInterno >= other.montoInterno;

  @override
  int get hashCode => _montoInterno.hashCode;
}
