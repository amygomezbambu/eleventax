import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';

class Articulo extends Entidad {
  final Producto? _producto;
  var _cantidad = 0.00;
  var _subtotal = Moneda(0);
  var _total = Moneda(0);
  var _totalImpuestos = Moneda(0);
  final DateTime _agregadoEn;
  late NombreProducto _descripcion;
  var _precioDeVenta = Moneda(0);

  Producto? get producto => _producto;
  double get cantidad => _cantidad;
  Moneda get subtotal => _subtotal;
  Moneda get totalImpuestos => _totalImpuestos;
  Moneda get total => _total;
  Moneda get precioDeVenta => _precioDeVenta;
  DateTime get agregadoEn => _agregadoEn;
  String get descripcion => _descripcion.value;

  Articulo.cargar({
    required UID uid,
    required Producto producto,
    required double cantidad,
    required Moneda subtotal,
    required Moneda totalImpuestos,
    required Moneda total,
    required DateTime agregadoEn,
    required Moneda precioDeVenta,
    required NombreProducto descripcion,
  })  : _producto = producto,
        _cantidad = cantidad,
        _subtotal = subtotal,
        _totalImpuestos = totalImpuestos,
        _total = total,
        _agregadoEn = agregadoEn,
        _precioDeVenta = precioDeVenta,
        _descripcion = descripcion,
        super.cargar(uid);

  Articulo.crear({
    required Producto producto,
    required double cantidad,
  })  : _producto = producto,
        _cantidad = cantidad,
        _agregadoEn = DateTime.now(),
        super.crear() {
    _descripcion = NombreProducto(producto.nombre);
    _precioDeVenta = producto.precioDeVenta!;
    _calcularTotales();
  }

  Articulo.crearDesdeProductoGenerico({
    required NombreProducto descripcion,
    required double cantidad,
    required Moneda precioDeVenta,
  })  : _descripcion = descripcion,
        _producto = null,
        _precioDeVenta = precioDeVenta,
        _cantidad = cantidad,
        _agregadoEn = DateTime.now(),
        super.crear() {
    _calcularTotales();
  }

  void actualizarCantidad(double cantidad) {
    _cantidad = cantidad;
  }

  void _calcularTotales() {
    _subtotal = Moneda(_precioDeVenta.toDouble() * _cantidad);
    //_totalImpuestos = _producto!.impuestos * _cantidad;
    _total = _subtotal + _totalImpuestos;
  }
}
