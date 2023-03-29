import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/ventas/read_models/total_impuesto.dart';

class ArticuloDto {
  var uid = "";
  var versionProductoUID = '';
  var cantidad = 0.00;
  var subtotal = Moneda(0);
  var agregadoEn = DateTime.now();
  bool esGenerico = false;
  var productoNombre = '';
  var productoCodigo = '';
  var precioDeVenta = Moneda(0);
  var totalesDeImpuestos = <TotalImpuestoDto>[];
}
