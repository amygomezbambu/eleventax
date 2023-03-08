import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';
import 'package:eleventa/modulos/ventas/ventas_ex.dart';
import 'package:collection/collection.dart';

enum EstadoDeVenta { enProgreso, cobrada, cancelada }

class Venta extends Entidad {
  final DateTime _creadoEn;
  final List<Articulo> _articulos;
  final List<TotalDeImpuesto> _totalesDeImpuestos;
  final List<Pago> _pagos;

  DateTime? _cobradaEn;
  EstadoDeVenta _estado;
  String? _folio;
  var _subtotal = Moneda(0);
  var _total = Moneda(0);
  var _totalImpuestos = Moneda(0);
  var _totalPagos = Moneda(0);

  String? get folio => _folio;
  EstadoDeVenta get estado => _estado;
  Moneda get totalPagos => _totalPagos;
  DateTime get creadoEn => _creadoEn;
  DateTime? get cobradaEn => _cobradaEn;
  Moneda get subtotal => _subtotal;
  Moneda get totalImpuestos => _totalImpuestos;
  Moneda get total => _total;
  List<Pago> get pagos => List.unmodifiable(_pagos);
  List<Articulo> get articulos => List.unmodifiable(_articulos);
  List<TotalDeImpuesto> get totalDeImpuestos =>
      List.unmodifiable(_totalesDeImpuestos);

  Venta.cargar({
    required UID uid,
    required EstadoDeVenta estado,
    required DateTime creadoEn,
    required Moneda subtotal,
    required Moneda totalImpuestos,
    required Moneda total,
    required List<Articulo> articulos,
    DateTime? cobradaEn,
    String? folio,
    List<Pago> pagos = const [],
  })  : _estado = estado,
        _folio = folio,
        _creadoEn = creadoEn,
        _cobradaEn = cobradaEn,
        _subtotal = subtotal,
        _totalImpuestos = totalImpuestos,
        _total = total,
        _articulos = articulos,
        _totalesDeImpuestos = [],
        _pagos = pagos,
        super.cargar(uid) {
    _actualizarTotales();
  }

  Venta.crear()
      : _estado = EstadoDeVenta.enProgreso,
        _creadoEn = DateTime.now(),
        _cobradaEn = null,
        _folio = null,
        _articulos = [],
        _totalesDeImpuestos = [],
        _pagos = [],
        super.crear();

  Venta copyWith({
    UID? uid,
    EstadoDeVenta? estado,
    DateTime? creadoEn,
    DateTime? cobradaEn,
    String? folio,
    Moneda? subtotal,
    Moneda? totalImpuestos,
    Moneda? total,
    List<Articulo>? articulos,
    List<Pago>? pagos,
  }) {
    return Venta.cargar(
      uid: uid ?? uid_,
      estado: estado ?? _estado,
      folio: folio ?? _folio,
      creadoEn: creadoEn ?? _creadoEn,
      cobradaEn: cobradaEn ?? _cobradaEn,
      subtotal: subtotal ?? _subtotal,
      totalImpuestos: totalImpuestos ?? _totalImpuestos,
      total: total ?? _total,
      articulos: articulos ?? [..._articulos],
      pagos: pagos ?? _pagos,
    );
  }

  void marcarComoCobrada({required String folio}) {
    _cobradaEn = DateTime.now();
    _estado = EstadoDeVenta.cobrada;
    _folio = folio;
  }

  void agregarPago(Pago pagoRecibido) {
    var sumatoriaDePagos =
        _pagos.fold(Moneda(0), (sumatoria, pago) => sumatoria + pago.monto);

    //0.001
    if (sumatoriaDePagos + pagoRecibido.monto > _total) {
      throw VentasEx(
          tipo: TiposVentasEx.errorDeValidacion,
          message:
              'la sumatoria de los pagos excede el total de la venta: ${sumatoriaDePagos + pagoRecibido.monto}');
    }

    _totalPagos += pagoRecibido.monto;
    _pagos.add(pagoRecibido);
  }

  void agregarArticulo(Articulo articulo) {
    var articuloExistenteConMismoProducto = _articulos.firstWhereOrNull(
        (articuloExistente) =>
            articuloExistente.producto.uid == articulo.producto.uid);

    if (articuloExistenteConMismoProducto != null) {
      var articuloActualizado = articuloExistenteConMismoProducto.copyWith(
        cantidad:
            articulo.cantidad + articuloExistenteConMismoProducto.cantidad,
      );
      actualizarArticulo(articuloActualizado);
    } else {
      _articulos.add(articulo);
      _actualizarTotales();
    }
  }

  void actualizarArticulo(Articulo articuloActualizado) {
    Articulo? articuloAnterior = _obtenerArticuloSiExiste(articuloActualizado);

    if (articuloAnterior != null) {
      _articulos.remove(articuloAnterior);
      _articulos.add(articuloActualizado);
    } else {
      throw VentasEx(
          tipo: TiposVentasEx.errorDeValidacion,
          message:
              'No se encontró el artículo con el uid: ${articuloActualizado.uid}');
    }

    _actualizarTotales();
  }

  Articulo? _obtenerArticuloSiExiste(Articulo articuloBuscado) {
    return _articulos
        .firstWhereOrNull((articulo) => articulo.uid == articuloBuscado.uid);
  }

  void eliminarArticulo(Articulo articulo) {
    var articuloExistenteConMismoProducto = _articulos.firstWhereOrNull(
        (articuloExistente) =>
            articuloExistente.producto.uid == articulo.producto.uid);

    if (articuloExistenteConMismoProducto != null) {
      var articuloActualizado = articuloExistenteConMismoProducto.copyWith(
        cantidad:
            articuloExistenteConMismoProducto.cantidad - articulo.cantidad,
      );

      if (articuloActualizado.cantidad == 0) {
        _articulos.remove(articuloActualizado);
      } else {
        actualizarArticulo(articuloActualizado);
      }

      _actualizarTotales();
    } else {
      throw VentasEx(
          tipo: TiposVentasEx.errorDeValidacion,
          message:
              'No se encontró el artículo con el uid: ${articulo.uid}');
    }
  }

  void _actualizarTotales() {
    _subtotal = Moneda(0);
    _totalImpuestos = Moneda(0);
    _total = Moneda(0);
    var impuestosDeVenta = <String, TotalDeImpuesto>{};
    var totalEsperadoPorCliente = 0.00;

    _totalesDeImpuestos.clear();

    for (var articulo in _articulos) {
      totalEsperadoPorCliente +=
          articulo.producto.precioDeVenta.toDouble() * articulo.cantidad;

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

    _total = _subtotal + _totalImpuestos;
    _subtotal = _subtotal.importeCobrable;
    _totalImpuestos = _totalImpuestos.importeCobrable;
    _total = _total.importeCobrable;

    ajustarTotales(totalEsperadoPorCliente);
  }

  void ajustarTotales(double totalEsperadoPorCliente) {
    var diferencia =
        Moneda(totalEsperadoPorCliente).importeCobrable.toDouble() -
            _total.toDouble();

    if (diferencia.abs() == 0.01) {
      _subtotal += Moneda(diferencia);
    }

    if (diferencia.abs() == 0.02) {
      _subtotal += Moneda(0.01);
      _totalImpuestos += Moneda(0.01);
    }

    _total = (_subtotal + _totalImpuestos).importeCobrable;
    //Map<String, Moneda> totalesPorImpuesto = {};

    //return Moneda(_producto.precioDeVentaSinImpuestos.toDouble() * _cantidad);

    // var precioSinImpuestos =
    //     Moneda(_producto!.precioDeVentaSinImpuestos.toDouble() * _cantidad)
    //         .redondearADecimales(3);

    // if (_producto == null || _producto!.impuestos.isEmpty) {
    //   return precioSinImpuestos;
    // }

    // final montoObjetivo =
    //     Moneda(producto!.precioDeVenta!.toDouble() * _cantidad);

    // var salir = false;

    // // 1. Ordenamos los impuestos en base al orden de aplicación
    // // para tomar como base para el IVA el precio mas IEPS por ejemplo
    // final impuestosDescendentes = [..._producto!.impuestos];

    // impuestosDescendentes
    //     .sort((a, b) => a.ordenDeAplicacion.compareTo(b.ordenDeAplicacion));

    // //Para forzar que sea una nueva referencia hacemos lo siguiente:
    // var baseDelImpuesto = Moneda(precioSinImpuestos.toDouble());

    // //redondear precio sin impuestos a 4 decimales redondeando
    // //19485.153247  -> 19485.154000 -> 19485.155000 -> 19485.156000 -> hasta encontrar valor

    // var contador = 1;

    // while (salir != true) {
    //   if (contador == 19) {
    //     break;
    //   }

    //   for (var impuesto in impuestosDescendentes) {
    //     final montoDeImpuesto =
    //         baseDelImpuesto.toDouble() * (impuesto.porcentaje / 100);

    //     totalesPorImpuesto[impuesto.nombre] = Moneda(montoDeImpuesto);

    //     baseDelImpuesto += Moneda(montoDeImpuesto);
    //   }

    //   var totalADosDecimales = precioSinImpuestos.importeCobrable;

    //   for (var importe in totalesPorImpuesto.values) {
    //     totalADosDecimales += importe.importeCobrable;
    //   }

    //   if (totalADosDecimales.importeCobrable == montoObjetivo.importeCobrable) {
    //     salir = true;
    //     print("Valor encontrado: ${precioSinImpuestos.toDouble().toString()}");
    //   } else {
    //     precioSinImpuestos = totalADosDecimales < montoObjetivo
    //         ? precioSinImpuestos + Moneda(0.001)
    //         : precioSinImpuestos - Moneda(0.001);

    //     baseDelImpuesto = Moneda(precioSinImpuestos.toDouble());
    //     totalesPorImpuesto = {};
    //   }

    //   contador++;
    // }

    //return precioSinImpuestos;
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
