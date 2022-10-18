import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  // group('Obtener item', () {
  //   test('Debe devolver un articulo cuando le demos un SKU válido', () async {
  //     const sku = '12345';
  //     final obtenerProducto = ModuloProductos.obtenerProducto();
  //     final crearProducto = ModuloProductos.crearProducto();

  //     crearProducto.req.sku = sku;
  //     crearProducto.req.descripcion = 'Coca Cola 600ml';
  //     crearProducto.req.precio = 10.50;

  //     var uid = await crearProducto.exec();

  //     obtenerProducto.req.sku = sku;
  //     final producto = await obtenerProducto.exec();

  //     expect(producto.sku, sku);
  //     expect(producto.uid, uid.toString());
  //   });

  //   test('Debe lanzar excepcion cuando proporcionemos un SKU inválido',
  //       () async {
  //     const sku = 'NO-EXISTE-EN-BD';
  //     final obtenerProducto = ModuloProductos.obtenerProducto();

  //     obtenerProducto.req.sku = sku;

  //     await expectLater(obtenerProducto.exec(), throwsA(isA<Exception>()));
  //   });
  // });
}
