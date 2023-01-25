import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe actualizar los totales al agregar nuevos articulos', () {
    var cantidad = 2.00;
    var precioVenta = 35.55444451111;
    var precioCompra = 21.54444448;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final subtotalEsperado = Moneda(precioVenta * cantidad).importeCobrable;

    // var totalDeImpuestos = Moneda(0);
    // for (var impuesto in producto.impuestos) {
    //   totalDeImpuestos +=
    // }

    //final totalImpuestosEsperados = Moneda(0).importeCobrable;

    //final totalEsperado = subtotalEsperado + totalImpuestosEsperados;

    expect(venta.subtotal, subtotalEsperado);
    // TODO: Probar lógica de total de impuestos y total a 2 decimales
    //expect(venta.totalImpuestos, totalImpuestosEsperados);
    //expect(venta.total, totalEsperado);
    //expect(venta.creadoEn, fechaEsperada);
  });

  //TODO: probar la comparacion de fechas entre la creacion del ticket y la establecida por la prueba
  test('Debe tener una fecha especificada al momento de crear la venta', () {
    //var fechaEsperada = DateTime.now();
  });
  test('Debe actualizar los totales al eliminar algun articulo', () {});

  test('Debe actualizar los totales al modificar un articulo', () {});
}
