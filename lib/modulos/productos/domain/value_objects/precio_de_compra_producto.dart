import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';

class PrecioDeCompraProducto {
  final _cero = 0;
  late Moneda _precio;

  Moneda get value => _precio;

  PrecioDeCompraProducto(Moneda precio) {
    _precio = precio;
    _validar(_precio);
  }

  void _validar(Moneda value) {
    if (value.montoInterno < _cero) {
      throw ValidationEx(
          mensaje: 'El precio de compra del producto no puede ser negativo');
    }

    if (!ModuloProductos.config.compartida.permitirPrecioCompraCero &&
        value.montoInterno == _cero) {
      throw ValidationEx(
          mensaje: 'El precio de compra del producto no puede ser cero');
    }
  }
}
