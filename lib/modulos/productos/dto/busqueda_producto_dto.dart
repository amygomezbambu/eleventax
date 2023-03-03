import 'package:eleventa/modulos/common/domain/moneda.dart';

class BusquedaProductoDto {
  var productoUid = '';
  var codigo = '';
  var nombre = '';
  var precioDeVenta = Moneda(0);
  var nombreCategoria = '';
}
