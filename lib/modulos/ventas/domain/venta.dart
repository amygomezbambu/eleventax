import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';

enum EstadoDeVenta { enProgreso, cobrada, cancelada }

class Venta extends Entidad {
  final EstadoDeVenta _estado;
  final DateTime _creadoEn;
  final List<Articulo> _articulos = [];
  var _subtotal = Moneda(0);
  var _total = Moneda(0);
  var _totalImpuestos = Moneda(0);

  EstadoDeVenta get estado => _estado;
  DateTime get creadoEn => _creadoEn;
  Moneda get subtotal => _subtotal;
  Moneda get totalImpuestos => _totalImpuestos;
  Moneda get total => _total;
  List<Articulo> get articulos => List.unmodifiable(_articulos);

  Venta.cargar({
    required UID uid,
    required EstadoDeVenta estado,
    required DateTime creadoEn,
    required Moneda subtotal,
    required Moneda totalImpuestos,
    required Moneda total,
  })  : _estado = estado,
        _creadoEn = creadoEn,
        _subtotal = subtotal,
        _totalImpuestos = totalImpuestos,
        _total = total,
        super.cargar(uid);

  Venta.crear()
      : _estado = EstadoDeVenta.enProgreso,
        _creadoEn = DateTime.now(),
        super.crear();

  void agregarArticulo(Articulo articulo) {
    _articulos.add(articulo);
    _actualizarTotales();
  }

  void _actualizarTotales() {
    _subtotal = Moneda(0);
    _totalImpuestos = Moneda(0);
    _total = Moneda(0);
    for (var articulo in _articulos) {
      _subtotal += articulo.subtotal;
      _totalImpuestos += articulo.totalImpuestos;
    }

    // Redondeamos a 2 decimales el subtotal
    _subtotal = Moneda(_subtotal.toString());
    _totalImpuestos = Moneda(_totalImpuestos.toString());
    _total = _subtotal + _totalImpuestos;
  }
}
