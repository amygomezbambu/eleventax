import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  group('Obtener item', () {
    test('Debe devolver un articulo cuando le demos un SKU válido', () async {
      var crearProducto = ModuloProductos.crearProducto();
      var obtenerProducto = ModuloProductos.obtenerProducto();

      const codigo = '123456';
      const nombre = 'Atun tunny 200 grs.';
      const precioDeVenta = 13.40;
      const precioDeCompra = 10.40;

      var producto = Producto.crear(
          codigo: codigo,
          nombre: nombre,
          precioDeVenta: precioDeVenta,
          precioDeCompra: precioDeCompra,
          unidadDeMedida: UnidadDeMedida(
            uid: UID(),
            nombre: 'Pieza',
            abreviacion: 'pz',
          ));

      crearProducto.req.producto = producto;

      await crearProducto.exec();

      obtenerProducto.req.uidProducto = producto.uid;

      final productoDeDB = await obtenerProducto.exec();

      expect(productoDeDB.codigo, codigo);
      expect(productoDeDB.uid, producto.uid);
    });

    test('Debe lanzar excepcion cuando proporcionemos un UID inválido',
        () async {
      final obtenerProducto = ModuloProductos.obtenerProducto();

      var uidQueNoExiste = UID();

      obtenerProducto.req.uidProducto = uidQueNoExiste;

      await expectLater(obtenerProducto.exec(), throwsA(isA<Exception>()));
    });
  });
}
