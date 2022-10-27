import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/productos/usecases/obtener_producto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  group('Obtener producto', () {
    test('Debe devolver un producto cuando le demos un UID válido', () async {
      var crearProducto = ModuloProductos.crearProducto();
      var obtenerProducto = ModuloProductos.obtenerProducto();
      var consultas = ModuloProductos.repositorioConsultaProductos();

      UnidadDeMedida unidadMedida =
          (await consultas.obtenerUnidadesDeMedida()).first;

      const codigo = '12345689';
      const nombre = 'Atun tunny 200 grs.';
      final precioDeVenta = Moneda(13.40);
      final precioDeCompra = Moneda(10.40);

      var producto = Producto.crear(
          codigo: codigo,
          nombre: nombre,
          precioDeVenta: precioDeVenta,
          precioDeCompra: precioDeCompra,
          unidadDeMedida: unidadMedida);

      crearProducto.req.producto = producto;

      await crearProducto.exec();

      obtenerProducto.req.uidProducto = producto.uid;
      obtenerProducto.req.tipoDeBusqueda = TipoDeBusqueda.uid;

      final productoDeDB = await obtenerProducto.exec();

      expect(productoDeDB.codigo, codigo);
      expect(productoDeDB.uid.toString(), producto.uid.toString());
      expect(productoDeDB.nombre, producto.nombre);
      expect(productoDeDB.precioDeVenta, producto.precioDeVenta);
      expect(productoDeDB.precioDeCompra, producto.precioDeCompra);
      expect(productoDeDB.imagenURL, producto.imagenURL);
      expect(productoDeDB.seVendePor, producto.seVendePor);
      expect(
        productoDeDB.unidadMedida.uid.toString(),
        producto.unidadMedida.uid.toString(),
      );
      expect(
        productoDeDB.categoria?.uid.toString(),
        producto.categoria?.uid.toString(),
      );

      // TODO: Realizar comparacion de los impuestos
      //expect(productoDeDB.impuestos, producto.impuestos);
    });

    test('Debe devolver un producto cuando le demos un CODIGO válido',
        () async {
      var crearProducto = ModuloProductos.crearProducto();
      var obtenerProducto = ModuloProductos.obtenerProducto();
      var consultas = ModuloProductos.repositorioConsultaProductos();

      UnidadDeMedida unidadMedida =
          (await consultas.obtenerUnidadesDeMedida()).first;

      const codigo = 'ABCDEF';
      const nombre = 'Atun tunny 200 grs.';
      final precioDeVenta = Moneda(13.40);
      final precioDeCompra = Moneda(10.40);

      var producto = Producto.crear(
          codigo: codigo,
          nombre: nombre,
          precioDeVenta: precioDeVenta,
          precioDeCompra: precioDeCompra,
          unidadDeMedida: unidadMedida);

      crearProducto.req.producto = producto;

      await crearProducto.exec();

      obtenerProducto.req.codigo = codigo;
      obtenerProducto.req.tipoDeBusqueda = TipoDeBusqueda.codigo;

      final productoDeDB = await obtenerProducto.exec();

      expect(productoDeDB.codigo, codigo);
      expect(productoDeDB.uid.toString(), producto.uid.toString());
      expect(productoDeDB.nombre, producto.nombre);
      expect(productoDeDB.precioDeVenta, producto.precioDeVenta);
      expect(productoDeDB.precioDeCompra, producto.precioDeCompra);
      expect(productoDeDB.imagenURL, producto.imagenURL);
      expect(productoDeDB.seVendePor, producto.seVendePor);
      expect(
        productoDeDB.unidadMedida.uid.toString(),
        producto.unidadMedida.uid.toString(),
      );
      expect(
        productoDeDB.categoria?.uid.toString(),
        producto.categoria?.uid.toString(),
      );

      // TODO: Realizar comparacion de los impuestos
      //expect(productoDeDB.impuestos, producto.impuestos);
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
