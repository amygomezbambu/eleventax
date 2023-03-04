import 'dart:io';

import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/adaptador_impresion_windows.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/impresora_tickets_windows.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../loader_for_tests.dart';
import '../../../../../utils/productos.dart';

void main() {
  setUpAll(() async {
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

    final cobrarVenta = ModuloVentas.cobrarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final formasDisponibles = await consultas.obtenerFormasDePago();

    const precio = 11.55;

    final impuestos = <Impuesto>[
      Impuesto.crear(
          nombre: 'IVA',
          porcentaje: PorcentajeDeImpuesto(16.0),
          ordenDeAplicacion: 2),
    ];

    final impuestoMultiples = <Impuesto>[
      Impuesto.crear(
          nombre: 'IEPS',
          porcentaje: PorcentajeDeImpuesto(8.0),
          ordenDeAplicacion: 1),
      ...impuestos,
    ];

    var producto = ProductosUtils.crearProducto(
      impuestos: impuestoMultiples,
      precioCompra: Moneda(precio),
      precioVenta: Moneda(precio),
    );

    Venta ventaEnProgreso = Venta.crear();
    var articulo = Articulo.crear(
      producto: producto,
      cantidad: 1.0,
    );
    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: Moneda(precio),
      pagoCon: Moneda(precio),
    );

    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    var venta = await consultas.obtenerVenta(ventaEnProgreso.uid);

    await adaptadorImpresion.imprimirTicket(venta!);
  }, skip: !Platform.isWindows);
}
