import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';

class PorcentajeDeImpuesto extends Moneda {
  static const porcentajeMinimo = 0.0;
  static const porcentajeMaximo = 100.0;

  /// Representa un porcentaje de impuesto
  ///
  /// [porcentaje] es un valor decimal entre 0 y 100
  ///
  /// ejemplo: 16.00 , 1.33
  PorcentajeDeImpuesto(dynamic porcentaje) : super(porcentaje) {
    if (this < Moneda(porcentajeMinimo) || this > Moneda(porcentajeMaximo)) {
      throw ValidationEx(
          mensaje: 'El porcentaje no está entre 0 y 100.',
          tipo: TipoValidationEx.valorFueraDeRango);
    }
  }

  /// Regresa el porcentaje como un valor entre 0 y 1. Ejemplo 0.16
  double toPorcentajeDecimal() {
    return toDouble() / 100;
  }

  PorcentajeDeImpuesto.deserialize(MonedaInt porcentaje)
      : super.deserialize(porcentaje);
}
