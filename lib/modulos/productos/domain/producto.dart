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
  var _precioDeVenta = Moneda(0);
  var _precioDeCompra = Moneda(0);
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

  set categoria(Categoria? val) => _categoria;

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
    _codigo = validarYAsignar<String>(codigo, validarCodigo);
    _nombre = validarYAsignar<String>(nombre, validarNombre);
    _precioDeCompra =
        validarYAsignar<Moneda>(precioDeCompra, validarPrecioDeCompra);
    //_categoria = validarYAsignar<String>(categoria, validarCategoria);

    if (precioDeVenta != null) {
      _precioDeVenta =
          validarYAsignar<Moneda>(precioDeVenta, validarPrecioDeVenta);
    }

    _categoria = categoria;
    _seVendePor = seVendePor;
    _imagenURL = imagenURL;
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

  static RespuestaValidacion validarCodigo(String value) {
    const codigoReservado = '0';

    RespuestaValidacion respuesta = RespuestaValidacion(esValido: true);

    if (value.isEmpty) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El código no puede estar vacío: $value',
      );
    }

    if (value.length > 20) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El código no puede tener mas de 20 letras',
      );
    }

    if (value == codigoReservado) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El codigo $codigoReservado no es un código valido',
      );
    }
    //TODO: revisar la correcta validacion del codigo y qué caracteres
    var regex = RegExp(r'[a-zA-Z0-9_\-=@,\.;]+$');
    if (!regex.hasMatch(value)) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El codigo contiene caracteres invalidos: $value',
      );
    }

    return respuesta;
  }

  static RespuestaValidacion validarPrecioDeVenta(Moneda value) {
    var respuesta = RespuestaValidacion(esValido: true);

    if (value <= Moneda(0)) {
      return respuesta = RespuestaValidacion(
        esValido: false,
        mensaje: 'El precio de venta debe ser mayor a cero',
      );
    }

    return respuesta;
  }

  // TODO: Ver cómo incluir el parametro , bool permitirPrecioCero
  static RespuestaValidacion validarPrecioDeCompra(Moneda value) {
    var respuesta = RespuestaValidacion(esValido: true);

    // if (permitirPrecioCero) {
    //   if (value < Moneda(0)) {
    //     respuesta = RespuestaValidacion(
    //       esValido: false,
    //       mensaje: 'El precio de compra, no puede ser negativo',
    //     );
    //   }
    // } else {
    if (value <= Moneda(0)) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El precio de compra, debe ser mayor a cero',
      );
    }
    //}

    return respuesta;
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

  static RespuestaValidacion validarNombre(String value) {
    var respuesta = RespuestaValidacion(esValido: true);
    //var regex = RegExp(r'[-~]+$');

    if (value.isEmpty) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El nombre no puede estar vacio',
      );
    }

    if (value.length > 130) {
      return RespuestaValidacion(
        esValido: false,
        mensaje: 'El nombre no puede tener más de 130 letras',
      );
    }

    // if (!regex.hasMatch(value)) {
    //   respuesta = RespuestaValidacion(
    //     esValido: false,
    //     mensaje: 'El nombre contiene caracteres invalidos: $value',
    //   );
    // }

    return respuesta;
  }
}
