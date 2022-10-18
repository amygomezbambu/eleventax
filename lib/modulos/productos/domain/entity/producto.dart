import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

enum ProductoSeVendePor { unidad, peso }

class Producto extends Entidad {
  var _nombre = '';
  var _precioDeVenta = 0.0;
  var _precioDeCompra = 0.0;
  var _categoria = '';
  //unidad medida
  // impuestos
  late ProductoSeVendePor _seVendePor;
  var _imagenURL = '';
  var _codigo = '';

  String get nombre => _nombre;
  double get precioDeVenta => _precioDeVenta;
  double get precioDeCompra => _precioDeCompra;
  String get categoria => _categoria;
  ProductoSeVendePor get seVendePor => _seVendePor;
  String get imagenURL => _imagenURL;
  String get codigo => _codigo;

  Producto.crear({
    required String nombre,
    required double precioDeVenta,
    required double precioDeCompra,
    String categoria = '',
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    required String codigo,
  }) : super.crear() {
    //TODO: agregar validaciones
    _nombre = nombre;
    _precioDeVenta = precioDeVenta;
    _precioDeCompra = precioDeCompra;
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _codigo = codigo;
  }

  Producto.cargar({
    required UID uid,
    required String nombre,
    required double precioDeVenta,
    required double precioDeCompra,
    String categoria = '',
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    required String codigo,
  }) : super.cargar(uid) {
    //TODO: agregar validaciones
    _nombre = nombre;
    _precioDeVenta = precioDeVenta;
    _precioDeCompra = precioDeCompra;
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _codigo = codigo;
  }

  void _validaCategoria(String value) {
    if (value.isEmpty) {
      throw Exception('La _categoria no puede estar vacia');
    }

    _categoria = value;
  }

  void _validarNombre(String value) {
    if (value.isEmpty) {
      throw Exception('La _nombre no puede estar vacia');
    }

    _nombre = value;
  }

  void _validarPrecioDeVenta(double value) {
    if (value <= 0) {
      throw Exception('El precio no pude ser cero');
    }

    _precioDeVenta = value;
  }
}
