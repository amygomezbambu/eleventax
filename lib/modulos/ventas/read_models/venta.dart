import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/read_models/articulo.dart';
import 'package:eleventa/modulos/ventas/read_models/pago.dart';
import 'package:eleventa/modulos/ventas/read_models/total_impuesto.dart';

class VentaDto {
  var uid = "";
  var estado = EstadoDeVenta.cobrada;
  var creadoEn = DateTime.now();
  DateTime? cobradaEn;
  var articulos = <ArticuloDto>[];
  var totalesDeImpuestos = <TotalImpuestoDto>[];
  var pagos = <PagoDto>[];
  var subtotal = Moneda(0);
  var total = Moneda(0);
  var totalImpuestos = Moneda(0);
}
