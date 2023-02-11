import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';

enum EstadoDeVenta { enProgreso, cobrada, cancelada }

class Venta extends Entidad {
  final DateTime _creadoEn;
  final List<Articulo> _articulos;
  final List<TotalDeImpuesto> _totalesDeImpuestos;
  final List<Pago> _pagos;

  DateTime? _cobradaEn;
  EstadoDeVenta _estado;
  var _subtotal = Moneda(0);
  var _total = Moneda(0);
  var _totalImpuestos = Moneda(0);

  EstadoDeVenta get estado => _estado;
  DateTime get creadoEn => _creadoEn;
  DateTime? get cobradaEn => _cobradaEn;
  Moneda get subtotal => _subtotal;
  Moneda get totalImpuestos => _totalImpuestos;
  Moneda get total => _total;
  List<Pago> get pagos => List.unmodifiable(_pagos);
  List<Articulo> get articulos => List.unmodifiable(_articulos);
  List<TotalDeImpuesto> get totalDeImpuestos =>
      List.unmodifiable(_totalesDeImpuestos);

  Venta.cargar(
      {required UID uid,
      required EstadoDeVenta estado,
      required DateTime creadoEn,
      required Moneda subtotal,
      required Moneda totalImpuestos,
      required Moneda total,
      required List<Articulo> articulos,
      DateTime? cobradaEn,
      List<TotalDeImpuesto> totalesDeImpuestos = const [],
      List<Pago> pagos = const []})
      : _estado = estado,
        _creadoEn = creadoEn,
        _cobradaEn = cobradaEn,
        _subtotal = subtotal,
        _totalImpuestos = totalImpuestos,
        _total = total,
        _articulos = articulos,
        _totalesDeImpuestos = totalesDeImpuestos,
        _pagos = pagos,
        super.cargar(uid) {
    _actualizarTotales();
  }

  Venta.crear()
      : _estado = EstadoDeVenta.enProgreso,
        _creadoEn = DateTime.now(),
        _cobradaEn = null,
        _articulos = [],
        _totalesDeImpuestos = [],
        _pagos = [],
        super.crear();

  Venta copyWith(
      {UID? uid,
      EstadoDeVenta? estado,
      DateTime? creadoEn,
      DateTime? cobradaEn,
      Moneda? subtotal,
      Moneda? totalImpuestos,
      Moneda? total,
      List<Articulo>? articulos,
      List<Pago>? pagos,
      List<TotalDeImpuesto>? totalesDeimpuestos}) {
    return Venta.cargar(
      uid: uid ?? uid_,
      estado: estado ?? _estado,
      creadoEn: creadoEn ?? _creadoEn,
      cobradaEn: cobradaEn ?? _cobradaEn,
      subtotal: subtotal ?? _subtotal,
      totalImpuestos: totalImpuestos ?? _totalImpuestos,
      total: total ?? _total,
      articulos: articulos ?? _articulos,
      pagos: pagos ?? _pagos,
      totalesDeImpuestos: totalesDeimpuestos ?? _totalesDeImpuestos,
    );
  }

  void cobrar() {
    _cobradaEn = DateTime.now();
    _estado = EstadoDeVenta.cobrada;
  }

  void agregarPago(Pago pagoRecibido) {
    var sumatoriaDePagos =
        _pagos.fold(Moneda(0), (sumatoria, pago) => sumatoria + pago.monto);

    if (sumatoriaDePagos + pagoRecibido.monto > _total) {
      throw ValidationEx(
          mensaje: 'la sumatoria de los pagos excede el total de la venta');
    }

    _pagos.add(pagoRecibido);
  }

  void agregarArticulo(Articulo articulo) {
    var encontrado = false;

    for (var element in _articulos) {
      if ((element.producto as Producto).uid == articulo.producto.uid) {
        element.actualizarCantidad(element.cantidad + articulo.cantidad);
        encontrado = true;
      }
    }

    if (!encontrado) {
      _articulos.add(articulo);
    }

    _actualizarTotales();
  }

  void _actualizarTotales() {
    _subtotal = Moneda(0);
    _totalImpuestos = Moneda(0);
    _total = Moneda(0);
    var impuestosDeVenta = <String, TotalDeImpuesto>{};

    _totalesDeImpuestos.clear();

    for (var articulo in _articulos) {
      _subtotal += articulo.subtotal;
      _totalImpuestos += articulo.totalImpuestos;

      for (var totalImpuestoDeArticulo in articulo.totalesDeImpuestos) {
        var totalImpuestoVenta =
            impuestosDeVenta[totalImpuestoDeArticulo.impuesto.uid.toString()];

        impuestosDeVenta[totalImpuestoDeArticulo.impuesto.uid.toString()] =
            totalImpuestoVenta == null
                ? TotalDeImpuesto(
                    base: totalImpuestoDeArticulo.base,
                    monto: totalImpuestoDeArticulo.monto,
                    impuesto: totalImpuestoDeArticulo.impuesto.copyWith(),
                  )
                : TotalDeImpuesto(
                    base:
                        totalImpuestoVenta.base + totalImpuestoDeArticulo.base,
                    monto: totalImpuestoVenta.monto +
                        totalImpuestoDeArticulo.monto,
                    impuesto: totalImpuestoDeArticulo.impuesto);
      }
    }

    _totalesDeImpuestos.addAll(impuestosDeVenta.values);

    // for (impuesto in impuestosArticulos.keys) {
    //   var totalDeImpuesto = TotalDeImpuesto(base: 0, monto: impuest, impuesto: impuesto)
    // }

    // Redondeamos a 2 decimales el subtotal
    // que es el que cobraremos a los usuarios
    _subtotal = _subtotal.importeCobrable;
    _totalImpuestos = _totalImpuestos.importeCobrable;
    _total = _subtotal + _totalImpuestos;
  }

  @override
  String toString() {
    var res = 'Impuestos: ${_totalesDeImpuestos.length}';
    for (var totalDeImpuesto in _totalesDeImpuestos) {
      res +=
          ' Impuesto: ${totalDeImpuesto.impuesto.nombre} - Base: \$${totalDeImpuesto.base}, Monto: \$${totalDeImpuesto.monto}';
    }

    return res;
  }
}
