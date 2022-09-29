import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

class Producto extends Entidad {
  var _descripcion = '';
  var _precio = 0.0;
  var _sku = '';

  String get descripcion => _descripcion;
  double get precio => _precio;
  String get sku => _sku;

  Producto.crear({
    required String descripcion,
    required double precio,
    required String sku,
  }) : super.crear() {
    _validarDescripcion(descripcion);
    _validarPrecio(precio);
    _validarSKU(sku);
  }

  Producto.cargar(
    UID uid,
    String sku,
    String descripcion,
    double precio,
  ) : super.cargar(uid) {
    _validarDescripcion(descripcion);
    _validarPrecio(precio);
    _validarSKU(sku);
  }

  void _validarDescripcion(String value) {
    if (value.isEmpty) {
      throw Exception('La descripcion no puede estar vacia');
    }

    _descripcion = value;
  }

  void _validarPrecio(double value) {
    if (value <= 0) {
      throw Exception('El precio no pude ser cero');
    }

    _precio = value;
  }

  void _validarSKU(String value) {
    if (value.isEmpty) {
      throw Exception('El sku no puede ser vacío');
    }

    _sku = value;
  }
}
