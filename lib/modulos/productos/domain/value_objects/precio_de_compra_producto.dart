// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';

class PrecioDeCompraProducto {
  late Moneda _precio;

  Moneda get value => _precio;

  PrecioDeCompraProducto(Moneda precio) {
    _precio = precio;
    _validar(_precio);
  }

  void _validar(Moneda value) {
    if (value.montoInterno < 0) {
      throw ValidationEx(
          mensaje: 'El precio de compra del producto no puede ser negativo');
    }

    if (!ModuloProductos.config.compartida.permitirPrecioCompraCero &&
        value.montoInterno == 0) {
      throw ValidationEx(
          mensaje: 'El precio de compra del producto no puede ser cero');
    }
  }

  @override
  String toString() => 'PrecioDeCompraProducto(precio: ${_precio.toString()})';
}
