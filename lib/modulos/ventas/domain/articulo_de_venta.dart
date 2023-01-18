import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:meta/meta.dart';

class ArticuloDeVenta {
  @protected
  late final UID _ventaUID;
  @protected
  late final UID? _productoUID;
  @protected
  late String _descripcion;
  @protected
  late double _precio;
  @protected
  late double _cantidad;

  ArticuloDeVenta(
      {required UID ventaUID,
      UID? productoUID,
      required String descripcion,
      required double precio,
      required double cantidad}) {
    _ventaUID = ventaUID;
    _productoUID = productoUID;

    _validarDescripcion(descripcion);
    _validarPrecio(precio);
    _validadCantidad(cantidad);
  }

  UID get ventaUID => _ventaUID;
  UID? get productoUID => _productoUID;
  String get descripcion => _descripcion;
  double get precio => _precio;
  double get cantidad => _cantidad;
  double get total => _precio * _cantidad;

  void _validarDescripcion(String value) {
    if (value.isEmpty) {
      throw DomainEx('La descripcion no puede estar vacia');
    }

    _descripcion = value;
  }

  void _validarPrecio(double value) {
    if (value <= 0) {
      throw DomainEx('El precio no pude ser cero');
    }

    _precio = value;
  }

  void _validadCantidad(double value) {
    if (value <= 0) {
      throw DomainEx('La cantidad no pude ser cero');
    }

    _cantidad = value;
  }
}
