import 'package:eleventa/modulos/common/domain/moneda.dart';

class PagoDto {
  var forma = "";
  var monto = Moneda(0);
  Moneda? pagoCon;
  String? referencia;
}
