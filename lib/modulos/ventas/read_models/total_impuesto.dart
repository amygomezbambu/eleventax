import 'package:eleventa/modulos/common/domain/moneda.dart';

class TotalImpuestoDto {
  var nombreImpuesto = "";
  var base = Moneda(0);
  var monto = Moneda(0);
  var porcentaje = 0.00;
}
