import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/domain/respuesta_de_validacion.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
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
    bool eliminado = false,
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
    bool eliminado = false,
  })  : _codigo = codigo,
        _nombre = nombre,
        _precioDeCompra = precioDeCompra,
        _precioDeVenta = precioDeVenta,
        super.cargar(uid, eliminado: eliminado) {
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

  Producto copyWith({
    UID? uid,
    NombreProducto? nombre,
    PrecioDeVentaProducto? precioDeVenta,
    PrecioDeCompraProducto? precioDeCompra,
    Categoria? categoria,
    UnidadDeMedida? unidadDeMedida,
    List<Impuesto>? impuestos,
    ProductoSeVendePor? seVendePor,
    String? imagenURL,
    CodigoProducto? codigo,
    bool? preguntarPrecio,
    bool? eliminado,
  }) {
    var uidAnterior = uid_.toString();

    var result = Producto.crear(
      codigo: codigo ?? _codigo,
      nombre: nombre ?? _nombre,
      precioDeVenta: precioDeVenta ?? _precioDeVenta,
      unidadDeMedida: unidadDeMedida ?? _unidadDeMedida,
      precioDeCompra: precioDeCompra ?? _precioDeCompra,
      categoria: categoria ?? _categoria,
      preguntarPrecio: preguntarPrecio ?? _preguntarPrecio,
      imagenURL: imagenURL ?? _imagenURL,
      seVendePor: seVendePor ?? _seVendePor,
      impuestos: impuestos ?? _impuestos,
    );

    result.uid_ = uid ?? UID.fromString(uidAnterior);
    result.eliminado_ = eliminado ?? eliminado_;

    return result;
  }
}
