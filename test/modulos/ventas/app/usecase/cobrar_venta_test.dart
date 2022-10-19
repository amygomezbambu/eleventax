// import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
// import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  // group('Cobrar venta', () {
  //   test('Se debe registrar el tipo de pago y la fecha del cobro', () async {
  //     var cobrarVenta = ModuloVentas.cobrarVenta();
  //     var crearVenta = ModuloVentas.crearVenta();
  //     var agregarArticulo = ModuloVentas.agregarArticulo();

  //     //when
  //     final uid = crearVenta.exec();

  //     agregarArticulo.req.articulo.descripcion = 'coca cola';
  //     agregarArticulo.req.articulo.precio = 10.56;
  //     agregarArticulo.req.articulo.cantidad = 2;
  //     agregarArticulo.req.ventaUID = uid;

  //     await agregarArticulo.exec();

  //     cobrarVenta.req.ventaUID = uid;
  //     cobrarVenta.req.metodoDePago = MetodoDePago.efectivo;

  //     await cobrarVenta.exec();

  //     var obtenerVenta = ModuloVentas.obtenerVenta();
  //     obtenerVenta.req.ventaUID = uid;
  //     var saleDTO = await obtenerVenta.exec();
  //     //expect

  //     //expect(saleDTO.status, SaleStatus.paid);
  //     expect(saleDTO.metodoDePago, MetodoDePago.efectivo);
  //     expect(saleDTO.fechaDePago, greaterThan(0));
  //   });

  //   test('Se debe marcar la venta como cobrada', () {});
  // });
}
