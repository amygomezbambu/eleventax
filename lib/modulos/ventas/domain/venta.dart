import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';
import 'package:eleventa/modulos/ventas/ventas_ex.dart';
// ignore: depend_on_referenced_packages
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
  List<Articulo> get articulos => List.unmodifiable(
      _articulos.sorted((a, b) => a.agregadoEn.compareTo(b.agregadoEn)));
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
          message: 'No se encontró el artículo con el uid: ${articulo.uid}');
    }
  }

  void _actualizarTotales() {
    _subtotal = Moneda(0);
    _totalImpuestos = Moneda(0);
    _total = Moneda(0);
    var impuestosDeVenta = <String, TotalDeImpuesto>{};

    _totalesDeImpuestos.clear();

    for (var articulo in _articulos) {
      _subtotal += articulo.subtotal;

      // Los totalesDeImpuestos de los articulos vienen a 6 decimales...
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

    // Una vez que tenemos los sumarizados de todos los impuestos los redondeamos a 2 decimales
    List<TotalDeImpuesto> totalesImpuestosRedondeados = [];
    for (var impuestoSumarizado in impuestosDeVenta.values) {
      var impuestoRedondeado = TotalDeImpuesto(
          base: impuestoSumarizado.base.importeCobrable,
          monto: impuestoSumarizado.monto.importeCobrable,
          impuesto: impuestoSumarizado.impuesto);

      totalesImpuestosRedondeados.add(impuestoRedondeado);
    }

    _totalesDeImpuestos.addAll(totalesImpuestosRedondeados);

    // La manera de sumarizar una venta es redondear el subtotal a 2 decimales
    _subtotal = _subtotal.importeCobrable;

    // Posteriormente, para cada total por impuesto y tasa, redondearlo tambien a 2 decimales
    for (var totalImpuesto in _totalesDeImpuestos) {
      _totalImpuestos += totalImpuesto.monto.importeCobrable;
    }

    // Finalmente el total será la suma del subtotal a 2 decimales + cada uno de sus impuestos a 2 decimales
    _total = _subtotal + _totalImpuestos;
  }

  @override
  String toString() {
    return '''
   Venta {
    UID: $uid_,
    Folio: $folio,    
    Estado: $_estado,
    Creado en: $_creadoEn,
    Cobrada en: $_cobradaEn,
    ----
    Articulos: $_articulos,
    ----    
    Subtotal: $_subtotal,
    Total Impuestos: $_totalImpuestos,
    Total: $_total,
    Totales Impuestos: $_totalesDeImpuestos
    Pagos: $_pagos,    
    }''';
  }
}
