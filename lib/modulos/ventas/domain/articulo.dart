import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';

class Articulo extends Entidad {
  final IProducto _producto;
  var _cantidad = 0.00;
  var _subtotal = Moneda(0);
  final DateTime _agregadoEn;
  var _precioDeVenta = Moneda(0);
  final List<TotalDeImpuesto> _totalesDeImpuestos;

  double get cantidad => _cantidad;
  Moneda get subtotal => _subtotal;
  Moneda get total => _subtotal + totalImpuestos;
  Moneda get precioDeVenta => _precioDeVenta;
  DateTime get agregadoEn => _agregadoEn;
  IProducto get producto => _producto;
  String get descripcion => _producto.nombre;

  List<TotalDeImpuesto> get totalesDeImpuestos =>
      List.unmodifiable(_totalesDeImpuestos);

  Moneda get totalImpuestos {
    var resultado = Moneda(0.00);
    for (var totalDeImpuesto in _totalesDeImpuestos) {
      resultado += totalDeImpuesto.monto;
    }

    return resultado;
  }

  Articulo.cargar({
    required UID uid,
    required double cantidad,
    required DateTime agregadoEn,
    required IProducto producto,
  })  : _cantidad = cantidad,
        _agregadoEn = agregadoEn,
        _producto = producto,
        _totalesDeImpuestos = [],
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
        _totalesDeImpuestos = [],
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

  void actualizarCantidad(double cantidad) {
    _cantidad = cantidad;
    _calcularTotales();
  }

  void _calcularTotales() {
    _subtotal =
        Moneda(_producto.precioDeVentaSinImpuestos.toDouble() * _cantidad);

    var baseDelImpuesto = _subtotal;

    var impuestosDescendentes = [..._producto.impuestos];
    impuestosDescendentes
        .sort((a, b) => a.ordenDeAplicacion.compareTo(b.ordenDeAplicacion));

    _totalesDeImpuestos.clear();

    for (var impuesto in impuestosDescendentes) {
      // TODO: Ver cómo multiplicar facilmente Moneda x double
      final montoDeImpuesto = baseDelImpuesto.toDouble() *
          impuesto.porcentaje.toPorcentajeDecimal();

      TotalDeImpuesto totalDeImpuesto = TotalDeImpuesto(
          base: baseDelImpuesto,
          monto: Moneda(montoDeImpuesto),
          impuesto: impuesto);

      _totalesDeImpuestos.add(totalDeImpuesto);

      baseDelImpuesto += Moneda(montoDeImpuesto);
    }
  }
}
