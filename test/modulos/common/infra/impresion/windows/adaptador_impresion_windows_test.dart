import 'dart:io';

import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/adaptador_impresion_windows.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/impresora_tickets_windows.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../../loader_for_tests.dart';
import '../../../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe obtener el listado de las impresoras instaladas', () async {
    var adaptadorImpresion = AdaptadorImpresionWindows();

    var listadoImpresoras =
        await adaptadorImpresion.obtenerImpresorasDisponibles();

    expect(
      listadoImpresoras.length,
      greaterThan(0),
    );
  }, skip: !Platform.isWindows);

  test('Debe imprimir una venta usando la impresora de tickets', () async {
    var adaptadorImpresion = AdaptadorImpresionWindows();

    var impresoraTickets = ImpresoraDeTicketsWindows(
      nombreImpresora: 'GP-5890X',
      anchoTicket: AnchoTicket.mm58,
    );

    adaptadorImpresion.impresoraTickets = impresoraTickets;

    final consultasProductos = ModuloProductos.repositorioConsultaProductos();
    final cobrarVenta = ModuloVentas.cobrarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final crearProducto = ModuloProductos.crearProducto();

    Venta ventaEnProgreso = Venta.crear();

    var cantidad = 1.00;

    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var listaImpuestos = await consultasProductos.obtenerImpuestos();

    var producto = ProductosUtils.crearProducto(
      impuestos: listaImpuestos,
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var formasDisponibles = await consultas.obtenerFormasDePago();

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    ventaEnProgreso.agregarArticulo(articulo);
    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: ventaEnProgreso.total,
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    await adaptadorImpresion.imprimirTicket(ventaCobrada!);
  }, skip: !Platform.isWindows);
}
