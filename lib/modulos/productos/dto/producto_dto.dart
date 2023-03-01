import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';

class UnidadDeMedidaDto {
  var nombre = '';
  var abreviacion = '';
}

class ProductoDto {
  var uid = ''; //Se usa actualmente para la versión del producto
  var productoUid = '';
  var codigo = '';
  var nombre = '';
  var precioDeVenta = Moneda(0);
  var precioDeCompra = Moneda(0);
  var nombreCategoria = '';
  var unidadDeMedida = UnidadDeMedidaDto();
  var seVendePor = ProductoSeVendePor.unidad;
  var imagenURL = '';
  var creadoEn = DateTime.now();
}
