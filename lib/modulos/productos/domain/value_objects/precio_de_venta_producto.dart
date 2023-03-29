// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';

class PrecioDeVentaProducto {
  late Moneda _precio;

  Moneda get value => _precio;

  PrecioDeVentaProducto(Moneda precio) {
    _precio = precio;
    _validar(_precio);
  }

  PrecioDeVentaProducto.sinPrecio() {
    _precio = Moneda(0);
  }

  void _validar(Moneda value) {
    if (value <= Moneda(0)) {
      throw ValidationEx(
          // TODO: Definir el tipo de excepcion correcta a lanzar
          tipo: TipoValidationEx.valorEnCero,
          mensaje: 'El precio debe ser mayor a cero');
    }
  }

  @override
  String toString() => 'PrecioDeVentaProducto(precio: ${_precio.toString()})';
}
