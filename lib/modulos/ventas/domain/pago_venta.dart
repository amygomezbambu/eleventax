import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';

class Pago {
  final FormaDePago forma;
  final Moneda monto;
  final Moneda? pagoCon;
  final String? referencia;

  Pago(
    this.forma,
    this.monto,
    this.pagoCon,
    this.referencia,
  );
}
