import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';

class PrecioDeVentaProducto {
  late Moneda _precio;

  Moneda get value => _precio;

  PrecioDeVentaProducto(Moneda precio) {
    _precio = precio;
    _validar(_precio);
  }

  void _validar(Moneda value) {
    if (value <= Moneda(0)) {
      throw ValidationEx(mensaje: 'El precio de venta debe ser mayor a cero');
    }
  }
}
