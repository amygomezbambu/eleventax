import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_precio_sin_impuestos.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_importe_con_impuestos.dart';

import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

class Articulo extends Entidad {
  final IProducto _producto;
  final double _cantidad;
  var _subtotal = Moneda(0);
  var _totalImpuestos = Moneda(0);
  final DateTime _agregadoEn;
  var _precioDeVenta = Moneda(0);
  final List<TotalDeImpuesto> _totalesDeImpuestos = [];

  double get cantidad => _cantidad;
  Moneda get subtotal => _subtotal;
  Moneda get total => Moneda(_producto.precioDeVenta.toDouble() * _cantidad);
  Moneda get precioDeVenta => _precioDeVenta;
  DateTime get agregadoEn => _agregadoEn;
  IProducto get producto => _producto;
  String get descripcion => _producto.nombre;

  List<TotalDeImpuesto> get totalesDeImpuestos =>
      List.unmodifiable(_totalesDeImpuestos);

  Moneda get totalImpuestos => _totalImpuestos;

  Articulo.cargar({
    required UID uid,
    required double cantidad,
    required DateTime agregadoEn,
    required IProducto producto,
  })  : _cantidad = cantidad,
        _agregadoEn = agregadoEn,
        _producto = producto,
        super.cargar(uid) {
    //TODO: validar que el precio de venta no sea cero, en este punto no debe
    //ser cero nunca
    _precioDeVenta = producto.precioDeVenta;
    _calcularTotales();
  }

  Articulo.crear({
    required IProducto producto,
    required double cantidad,
  })  : _cantidad = cantidad,
        _agregadoEn = DateTime.now(),
        _producto = producto,
        super.crear() {
    _precioDeVenta = producto.precioDeVenta;
    _validarCantidad(cantidad, producto.seVendePor);
    _calcularTotales();
  }

  /// Valida que la cantidad este dentro del rango, dependiendo de si el producto
  /// se vende por unidad o por peso(granel)
  /// Si el producto se vende por unidad, la cantidad debe ser un número entero
  /// Si el producto se vende por peso(granel), la cantidad debe ser mayor a 0.001Kg (1 gramo)
  void _validarCantidad(double cantidad, ProductoSeVendePor seVendePor) {
    const double limiteInferior = 0.001;

    if (seVendePor == ProductoSeVendePor.unidad && cantidad % 1 != 0) {
      throw ValidationEx(
        mensaje: 'La cantidad debe ser un número entero',
        tipo: TipoValidationEx.valorFueraDeRango,
      );
    }

    if (seVendePor == ProductoSeVendePor.peso && cantidad < limiteInferior) {
      throw ValidationEx(
        mensaje: 'La cantidad debe ser mayor o igual a $limiteInferior}',
        tipo: TipoValidationEx.valorFueraDeRango,
      );
    }
  }

  void _calcularTotales() {
    var precioSinImpuestosCalculado = calcularPrecioSinImpuestos(
      PrecioDeVentaProducto(_producto.precioDeVenta),
      _producto.impuestos,
      paraCantidad: _cantidad,
    );

    var importesDeArticulo = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestosCalculado),
      _producto.impuestos,
      paraCantidad: _cantidad,
      comoImportesCobrables: false,
    );

    _subtotal = importesDeArticulo.subtotal;
    _totalesDeImpuestos.clear();
    _totalesDeImpuestos.addAll(importesDeArticulo.totalesDeImpuestos);
    _totalImpuestos = importesDeArticulo.totalImpuestos;
  }

  Articulo copyWith({
    UID? uid,
    double? cantidad,
    Moneda? precioDeVenta,
    DateTime? agregadoEn,
    IProducto? producto,
  }) {
    return Articulo.cargar(
      uid: uid ?? uid_,
      cantidad: cantidad ?? this.cantidad,
      agregadoEn: agregadoEn ?? this.agregadoEn,
      producto: producto ?? this.producto,
    );
  }

  @override
  String toString() {
    return '''
            Articulo {producto: $_producto, cantidad: $_cantidad, subtotal: ${_subtotal.montoInterno}, agregadoEn: $_agregadoEn, 
            totalesDeImpuestos: $_totalesDeImpuestos}
          ''';
  }
}
