import 'package:eleventa/modulos/common/domain/moneda.dart';
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

  group('Obtener producto', () {
    test('Debe devolver un producto cuando le demos un código válido',
        () async {
      var crearProducto = ModuloProductos.crearProducto();
      var obtenerProducto = ModuloProductos.obtenerProducto();
      var consultas = ModuloProductos.repositorioConsultaProductos();

      UnidadDeMedida unidadMedida =
          (await consultas.obtenerUnidadesDeMedida()).first;

      const codigo = '123456';
      const nombre = 'Atun tunny 200 grs.';
      final precioDeVenta = Moneda.fromDouble(13.40);
      final precioDeCompra = Moneda.fromDouble(10.40);

      var producto = Producto.crear(
          codigo: codigo,
          nombre: nombre,
          precioDeVenta: precioDeVenta,
          precioDeCompra: precioDeCompra,
          unidadDeMedida: unidadMedida);

      crearProducto.req.producto = producto;

      await crearProducto.exec();

      obtenerProducto.req.uidProducto = producto.uid;

      final productoDeDB = await obtenerProducto.exec();

      expect(productoDeDB.codigo, codigo);
      expect(productoDeDB.uid.toString(), producto.uid.toString());
      expect(productoDeDB.nombre, producto.nombre);

      // TODO: Realizar comparacion con nueva clase de Moneda
      //expect(productoDeDB.precioDeVenta, producto.precioDeVenta);
      //expect(productoDeDB.precioDeCompra, producto.precioDeCompra);

      expect(productoDeDB.categoria?.uid.toString(),
          producto.categoria?.uid.toString());
      expect(productoDeDB.imagenURL, producto.imagenURL);
      expect(productoDeDB.unidadMedida.uid.toString(),
          producto.unidadMedida.uid.toString());
      // TODO: Realizar comparacion de los impuestos
      //expect(productoDeDB.impuestos, producto.impuestos);
      expect(productoDeDB.seVendePor, producto.seVendePor);
    });

    // test('Debe lanzar excepcion cuando proporcionemos un UID inválido',
    //     () async {
    //   final obtenerProducto = ModuloProductos.obtenerProducto();

    //   var uidQueNoExiste = UID();

    //   obtenerProducto.req.uidProducto = uidQueNoExiste;

    //   await expectLater(obtenerProducto.exec(), throwsA(isA<Exception>()));
    // });
  });
}
