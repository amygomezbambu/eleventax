// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/domain/servicio/calcular_precio_sin_impuesto_de_producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

enum ProductoSeVendePor { unidad, peso }

class Producto extends Entidad implements IProducto {
  final NombreProducto _nombre;
  final PrecioDeVentaProducto _precioDeVenta;
  final PrecioDeCompraProducto _precioDeCompra;
  Categoria? _categoria;
  late UnidadDeMedida _unidadDeMedida;
  List<Impuesto> _impuestos = [];
  late ProductoSeVendePor _seVendePor;
  var _imagenURL = '';
  final CodigoProducto _codigo;
  bool _preguntarPrecio = false;
  final UID _versionActual;

  Moneda get precioDeCompra => _precioDeCompra.value;
  Categoria? get categoria => _categoria;
  ProductoSeVendePor get seVendePor => _seVendePor;
  String get imagenURL => _imagenURL;

  UnidadDeMedida get unidadMedida => _unidadDeMedida;
  bool get preguntarPrecio => _preguntarPrecio;

  @override
  UID get versionActual => _versionActual;

  @override
  String get nombre => _nombre.value;
  @override
  String get codigo => _codigo.value;
  @override
  Moneda get precioDeVenta => _precioDeVenta.value;
  @override
  List<Impuesto> get impuestos => List.unmodifiable(_impuestos);
  @override
  Moneda get precioDeVentaSinImpuestos =>
      calcularPrecioSinImpuestos(_precioDeVenta, _impuestos);

  set categoria(Categoria? val) => _categoria;

  Producto.crear({
    required CodigoProducto codigo,
    required NombreProducto nombre,
    required UnidadDeMedida unidadDeMedida,
    required PrecioDeCompraProducto precioDeCompra,
    required PrecioDeVentaProducto precioDeVenta,
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
        _versionActual = UID(),
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
    required PrecioDeVentaProducto precioDeVenta,
    Categoria? categoria,
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    required CodigoProducto codigo,
    List<Impuesto> impuestos = const [],
    required UnidadDeMedida unidadDeMedida,
    required bool preguntarPrecio,
    required UID versionActual,
    bool eliminado = false,
  })  : _codigo = codigo,
        _nombre = nombre,
        _precioDeCompra = precioDeCompra,
        _precioDeVenta = precioDeVenta,
        _versionActual = versionActual,
        super.cargar(uid, eliminado: eliminado) {
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _impuestos = impuestos;
    _unidadDeMedida = unidadDeMedida;
    _preguntarPrecio = preguntarPrecio;
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
    UID? versionActual,
  }) {
    var result = Producto.cargar(
      uid: uid ?? uid_,
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
      versionActual: versionActual ?? _versionActual,
    );

    //TODO: decidir eliminado o borrado ?, borrado se requiere por la sync
    result.eliminado_ = eliminado ?? eliminado_;

    return result;
  }

  @override
  String toString() {
    return 'Producto(UID: ${super.uid.toString()}, nombre: ${_nombre.value}, '
        'precioDeVenta: ${_precioDeVenta.toString()}, '
        'precioDeCompra: ${_precioDeCompra.toString()}, '
        'categoria: ${_categoria?.nombre}, '
        'unidadDeMedida: ${_unidadDeMedida.nombre}, '
        'seVendePor: ${_seVendePor.name}, '
        'codigo: ${_codigo.value})'
        'versionActual: ${_versionActual.toString()})';
  }
}
