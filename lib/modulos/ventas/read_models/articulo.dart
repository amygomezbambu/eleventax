import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/ventas/read_models/total_impuesto.dart';

class ArticuloDto {
  var uid = "";
  var cantidad = 0.00;
  var subtotal = Moneda(0);
  var agregadoEn = DateTime.now();
  var descripcion = "";
  var precioDeVenta = Moneda(0);
  var totalesDeImpuestos = <TotalImpuestoDto>[];
}
