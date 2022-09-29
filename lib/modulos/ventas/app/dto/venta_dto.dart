import 'package:eleventa/modulos/ventas/app/dto/articulo_de_venta.dart';

import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';

class VentaDTO {
  var uid = '';
  var name = '';
  var total = 0.0;
  var status = EstadoDeVenta.abierta;
  MetodoDePago? metodoDePago;
  int? fechaDePago;
  var articulos = <ArticuloDTO>[];
}
