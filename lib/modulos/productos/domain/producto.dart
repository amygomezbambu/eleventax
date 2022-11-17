import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/respuesta_de_validacion.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';

import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

enum ProductoSeVendePor { unidad, peso }

class Producto extends Entidad {
  final NombreProducto _nombre;
  final PrecioDeVentaProducto? _precioDeVenta;
  final PrecioDeCompraProducto _precioDeCompra;
  Categoria? _categoria;
  late UnidadDeMedida _unidadDeMedida;
  List<Impuesto> _impuestos = [];
  late ProductoSeVendePor _seVendePor;
  var _imagenURL = '';
  final CodigoProducto _codigo;
  bool _preguntarPrecio = false;

  String get nombre => _nombre.value;
  Moneda? get precioDeVenta => _precioDeVenta?.value;
  Moneda get precioDeCompra => _precioDeCompra.value;
  Categoria? get categoria => _categoria;
  ProductoSeVendePor get seVendePor => _seVendePor;
  String get imagenURL => _imagenURL;
  String get codigo => _codigo.value;
  UnidadDeMedida get unidadMedida => _unidadDeMedida;
  List<Impuesto> get impuestos => List.unmodifiable(_impuestos);
  bool get preguntarPrecio => _preguntarPrecio;

  set categoria(Categoria? val) => _categoria;

  Producto.crear({
    required CodigoProducto codigo,
    required NombreProducto nombre,
    required UnidadDeMedida unidadDeMedida,
    required PrecioDeCompraProducto precioDeCompra,
    PrecioDeVentaProducto? precioDeVenta,
    Categoria? categoria,
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    List<Impuesto> impuestos = const [],
    bool preguntarPrecio = false,
  })  : _codigo = codigo,
        _nombre = nombre,
        _precioDeCompra = precioDeCompra,
        _precioDeVenta = precioDeVenta,
        super.crear() {
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _impuestos = impuestos;
    _unidadDeMedida = unidadDeMedida;
    _preguntarPrecio = preguntarPrecio;
  }

  Producto.cargar({
    required UID uid,
    required NombreProducto nombre,
    required PrecioDeCompraProducto precioDeCompra,
    PrecioDeVentaProducto? precioDeVenta,
    Categoria? categoria,
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    required CodigoProducto codigo,
    List<Impuesto> impuestos = const [],
    required UnidadDeMedida unidadDeMedida,
    required bool preguntarPrecio,
  })  : _codigo = codigo,
        _nombre = nombre,
        _precioDeCompra = precioDeCompra,
        _precioDeVenta = precioDeVenta,
        super.cargar(uid) {
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _impuestos = impuestos;
    _unidadDeMedida = unidadDeMedida;
    _preguntarPrecio = preguntarPrecio;
  }

  static RespuestaValidacion validarCategoria(String value) {
    var respuesta = RespuestaValidacion(esValido: true);

    if (value.isEmpty) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'La categoria no puede estar vacia',
      );
    }

    return respuesta;
  }

  @override
  String toString() {
    return 'codigo: $codigo \n'
        'nombre: $nombre\n'
        'categoria: $categoria\n'
        'unidadMedida: $unidadMedida\n'
        'precioDeVenta: $precioDeVenta\n'
        'precioDeCompra: $precioDeCompra\n'
        'impuestos: $impuestos\n'
        'imagenURL: $imagenURL\n'
        'seVendePor: $seVendePor\n'
        'preguntarPrecio: $preguntarPrecio\n';
  }
}
