import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
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

  Producto llenarProductoConCodigo(String codigo) {
    const nombre = 'Atun tunny 200 grs.';
    final precioDeVenta = Moneda.fromDouble(13.40);
    final precioDeCompra = Moneda.fromDouble(10.40);

    var producto = Producto.crear(
        codigo: codigo,
        nombre: nombre,
        precioDeVenta: precioDeVenta,
        precioDeCompra: precioDeCompra,
        categoria: Categoria(uid: UID(), nombre: 'Refrescos'),
        unidadDeMedida: UnidadDeMedida(
          uid: UID(),
          nombre: 'Pieza',
          abreviacion: 'pz',
        ));

    return producto;
  }

  test('debe persistir el producto con opciones minimas', () async {
    var crearProducto = ModuloProductos.crearProducto();
    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda.fromDouble(10.40);

    var producto = Producto.crear(
        codigo: '2343Q34',
        nombre: nombre,
        precioDeCompra: precioDeCompra,
        unidadDeMedida: UnidadDeMedida(
          uid: UID(),
          nombre: 'Pieza',
          abreviacion: 'pz',
        ));

    crearProducto.req.producto = producto;

    await expectLater(
      crearProducto.exec(),
      completes,
    );
  });

  test('debe persistir el producto con todas sus propiedades', () async {
    var crearProducto = ModuloProductos.crearProducto();

    crearProducto.req.producto = llenarProductoConCodigo('ABC');

    await expectLater(
      crearProducto.exec(),
      completes,
    );
  });

  test('debe lanzar una excepcion si el codigo existe', () async {
    var crearProducto = ModuloProductos.crearProducto();
    crearProducto.req.producto = llenarProductoConCodigo('12345-3323');

    await crearProducto.exec();

    // TODO: Ver como evitar que se loguee la excepcion y nos cause ruido en los logs
    await expectLater(crearProducto.exec(), throwsA(isA<AppEx>()));
  });

  test('debe persistir el producto con categoria "sin categoria"', () async {
    var crearProducto = ModuloProductos.crearProducto();

    crearProducto.req.producto = llenarProductoConCodigo('S34gj4');
    crearProducto.req.producto.categoria =
        Categoria(uid: UID.invalid(), nombre: 'Sin Categoria');

    await expectLater(
      crearProducto.exec(),
      completes,
    );
  });
}
