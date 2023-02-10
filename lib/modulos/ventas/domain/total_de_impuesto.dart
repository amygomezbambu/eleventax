import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';

class TotalDeImpuesto {
  final Impuesto _impuesto;
  final Moneda _base;
  final Moneda _monto;

  Moneda get base => _base;
  Moneda get monto => _monto;
  Impuesto get impuesto => _impuesto;

  TotalDeImpuesto({
    required Moneda base,
    required Moneda monto,
    required Impuesto impuesto,
  })  : _base = base,
        _monto = monto,
        _impuesto = impuesto;

  @override
  String toString() {
    return '_totalDeImpuesto: base: $_base, monto: $_monto';
  }
}
