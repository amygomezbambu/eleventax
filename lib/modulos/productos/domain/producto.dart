import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/respuesta_de_validacion.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';

import 'package:eleventa/modulos/common/domain/moneda.dart';

enum ProductoSeVendePor { unidad, peso }

class Producto extends Entidad {
  var _nombre = '';
  var _precioDeVenta = Moneda.fromDouble(0);
  var _precioDeCompra = Moneda.fromDouble(0);
  Categoria? _categoria;
  late UnidadDeMedida _unidadDeMedida;
  List<Impuesto> _impuestos = [];
  late ProductoSeVendePor _seVendePor;
  var _imagenURL = '';
  var _codigo = '';
  bool _preguntarPrecio = false;

  String get nombre => _nombre;
  Moneda get precioDeVenta => _precioDeVenta;
  Moneda get precioDeCompra => _precioDeCompra;
  Categoria? get categoria => _categoria;
  ProductoSeVendePor get seVendePor => _seVendePor;
  String get imagenURL => _imagenURL;
  String get codigo => _codigo;
  UnidadDeMedida get unidadMedida => _unidadDeMedida;
  List<Impuesto> get impuestos => List.unmodifiable(_impuestos);
  bool get preguntarPrecio => _preguntarPrecio;

  Producto.crear({
    required String nombre,
    required Moneda precioDeCompra,
    Categoria? categoria,
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    required String codigo,
    List<Impuesto> impuestos = const [],
    required UnidadDeMedida unidadDeMedida,
    Moneda? precioDeVenta,
    bool preguntarPrecio = false,
  }) : super.crear() {
    //TODO: agregar validaciones
    _nombre = validarYAsignar<String>(nombre, validarNombre);
    //_categoria = validarYAsignar<String>(categoria, validarCategoria);

    if (precioDeVenta != null) {
      _precioDeVenta = precioDeVenta;
    }

    _precioDeCompra = precioDeCompra;
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _codigo = codigo;
    _impuestos = impuestos;
    _unidadDeMedida = unidadDeMedida;
    _preguntarPrecio = preguntarPrecio;
  }

  Producto.cargar({
    required UID uid,
    required String nombre,
    required Moneda precioDeVenta,
    required Moneda precioDeCompra,
    Categoria? categoria,
    ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad,
    String imagenURL = '',
    required String codigo,
    List<Impuesto> impuestos = const [],
    required UnidadDeMedida unidadDeMedida,
    required bool preguntarPrecio,
  }) : super.cargar(uid) {
    //TODO: agregar validaciones
    _nombre = nombre;
    _precioDeVenta = precioDeVenta;
    _precioDeCompra = precioDeCompra;
    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
    _codigo = codigo;
    _impuestos = impuestos;
    _unidadDeMedida = unidadDeMedida;
    _preguntarPrecio = preguntarPrecio;
  }

  RespuestaValidacion validarCategoria(String value) {
    RespuestaValidacion respuesta;

    if (value.isEmpty) {
      respuesta = RespuestaValidacion(
        esValido: false,
        mensaje: 'La categoria no puede estar vacia',
      );
    }

    respuesta = RespuestaValidacion(
      esValido: true,
      mensaje: '',
    );

    return respuesta;
  }

  RespuestaValidacion validarNombre(String value) {
    RespuestaValidacion respuesta;

    if (value.isEmpty) {
      respuesta = RespuestaValidacion(
        esValido: false,
        mensaje: 'El nombre no puede estar vacio',
      );
    }

    respuesta = RespuestaValidacion(
      esValido: true,
      mensaje: '',
    );

    return respuesta;
  }
}
