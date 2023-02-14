import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';

class Articulo extends Entidad {
  final IProducto _producto;
  var _cantidad = 0.00;
  var _subtotal = Moneda(0);
  final DateTime _agregadoEn;
  late NombreProducto _descripcion;
  var _precioDeVenta = Moneda(0);
  final List<TotalDeImpuesto> _totalesDeImpuestos;

  double get cantidad => _cantidad;
  Moneda get subtotal => _subtotal;
  Moneda get total => _subtotal + totalImpuestos;
  Moneda get precioDeVenta => _precioDeVenta;
  DateTime get agregadoEn => _agregadoEn;
  String get descripcion => _descripcion.value;
  IProducto get producto => _producto;

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
    required NombreProducto descripcion,
    required Producto producto,
  })  : _cantidad = cantidad,
        _agregadoEn = agregadoEn,
        _descripcion = descripcion,
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
    _descripcion = NombreProducto(producto.nombre);
    _precioDeVenta = producto.precioDeVenta!;
    _calcularTotales();
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
      final montoDeImpuesto =
          baseDelImpuesto.toDouble() * (impuesto.porcentaje / 100);

      TotalDeImpuesto totalDeImpuesto = TotalDeImpuesto(
          base: baseDelImpuesto,
          monto: Moneda(montoDeImpuesto),
          impuesto: impuesto);

      _totalesDeImpuestos.add(totalDeImpuesto);

      baseDelImpuesto += Moneda(montoDeImpuesto);
    }
  }
}
