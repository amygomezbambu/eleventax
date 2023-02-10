import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe lanzar una excepcion si la venta tiene un total en cero', () {
    // TODO: Implement test
  });

  test('debe almacenar los datos de la venta al registrar el cobro', () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    var consultas = ModuloVentas.repositorioConsultaVentas();

    Venta ventaEnProgreso = Venta.crear();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    var formasDisponibles = await consultas.obtenerFormasDePago();
    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: Moneda(24411.00),
    );

    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    // TODO: Ver cómo comparar la fecha/hora de cobro
    // date1.isAtSameMomentAs(date2) returns bool.
    /* date1.compareTo(date2),
       a negative value if this DateTime isBefore other.
       0 if this DateTime isAtSameMomentAs other, and
       a positive value otherwise (when this DateTime isAfter other)
     */
    expect(ventaCobrada, isNotNull);
    expect(ventaCobrada!.cobradaEn, isNotNull);
    expect(ventaCobrada.subtotal, ventaEnProgreso.subtotal);
    expect(ventaCobrada.totalImpuestos, ventaEnProgreso.totalImpuestos);
    expect(ventaCobrada.total, ventaEnProgreso.total);
    expect(ventaCobrada.estado, EstadoDeVenta.cobrada);

    expect(
      ventaCobrada.articulos.length,
      ventaEnProgreso.articulos.length,
      reason:
          'Los articulos cobrados no fueron los mismos que la venta en progreso',
    );
  });

  test('debe vaciar el queue de ventas en progreso al guardar la venta', () {
    // TODO: Implement test
  });

  test('debe lanzar error si las formas de pago exceden el total de la venta',
      () {
    // TODO: Implement test
  });
}
