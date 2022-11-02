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

  Producto llenarProductoConCodigo(String codigo,
      {double precioCompra = 10.30,
      double precioVenta = 13.40,
      String nombre = '🐟 Atun tunny 200 grs. 👋'}) {
    final precioDeCompra = Moneda(precioCompra);
    final precioDeVenta = Moneda(precioVenta);

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
    final precioDeCompra = Moneda(10.40);

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

    // Lo creamos la primera vez, debe pasar
    await crearProducto.exec();

    // Al crearlo por segunda vez, debe tronar
    await expectLater(crearProducto.exec(), throwsA(isA<AppEx>()));
  });

  test('debe lanzar una excepcion si alguna de las propiedades es inválida',
      () async {
    // Codigo - Que no pueda ser vacio
    expect(() => llenarProductoConCodigo(''), throwsA(isA<DomainEx>()));

    // Codigo - No debe aceptar mas de 20 caracteres
    expect(() => llenarProductoConCodigo('123456789123456789999'),
        throwsA(isA<DomainEx>()));

    // Codigo - No debemos permitir espacios
    expect(() => llenarProductoConCodigo('  '), throwsA(isA<DomainEx>()));

    // Codigo - Validar que no se pueda crear producto con código inválido
    expect(() => llenarProductoConCodigo('‎'), throwsA(isA<DomainEx>()));

    // Codigo - No puede ser el reservado para Venta Rapida
    expect(() => llenarProductoConCodigo('0'), throwsA(isA<DomainEx>()));

    // Código - No debe permitir caracteres inválidos (emoji)
    expect(() => llenarProductoConCodigo('💥'), throwsA(isA<DomainEx>()));

    // Código - No debe permitir caracteres inválidos (otros)
    expect(() => llenarProductoConCodigo('&'), throwsA(isA<DomainEx>()));

    // Precio de compra - Que no pueda ser negativo
    expect(() => llenarProductoConCodigo('INVALIDO-COMPRA', precioCompra: -1),
        throwsA(isA<DomainEx>()));

    // Precio de venta - Que no pueda ser negativo
    expect(() => llenarProductoConCodigo('INVALIDO-VENTA', precioVenta: 0),
        throwsA(isA<DomainEx>()));
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
