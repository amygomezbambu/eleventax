import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
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
        codigo: CodigoProducto(codigo),
        nombre: NombreProducto(nombre),
        precioDeVenta: PrecioDeVentaProducto(precioDeVenta),
        precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
        categoria: Categoria.crear(nombre: NombreCategoria('Refrescos')),
        unidadDeMedida: UnidadDeMedida.crear(
          nombre: 'Pieza',
          abreviacion: 'pz',
        ));

    return producto;
  }

  test('debe persistir el producto con opciones minimas', () async {
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloProductos.repositorioConsultaProductos();
    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var producto = Producto.crear(
        codigo: CodigoProducto('2343Q34'),
        nombre: NombreProducto(nombre),
        precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
        precioDeVenta: PrecioDeVentaProducto(precioDeCompra),
        unidadDeMedida: UnidadDeMedida.crear(
          nombre: 'Pieza',
          abreviacion: 'pz',
        ));

    crearProducto.req.producto = producto;

    await crearProducto.exec();
    final productoObtenido = await consultas.obtenerProducto(producto.uid);
    expect(productoObtenido!.codigo, producto.codigo);
  }, skip: true);

  test('debe persistir el producto cuando querramos que pregunte el precio',
      () async {
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloProductos.repositorioConsultaProductos();
    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var producto = Producto.crear(
        codigo: CodigoProducto('2343Q34'),
        nombre: NombreProducto(nombre),
        precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
        precioDeVenta: PrecioDeVentaProducto.sinPrecio(),
        preguntarPrecio: true,
        unidadDeMedida: UnidadDeMedida.crear(
          nombre: 'Pieza',
          abreviacion: 'pz',
        ));

    crearProducto.req.producto = producto;

    await crearProducto.exec();
    final productoObtenido = await consultas.obtenerProducto(producto.uid);
    expect(productoObtenido!.preguntarPrecio, true);
  }, skip: true);

  test('debe persistir el producto con todas sus propiedades', () async {
    var crearProducto = ModuloProductos.crearProducto();
    final consultas = ModuloProductos.repositorioConsultaProductos();
    final producto = llenarProductoConCodigo('ABC');
    crearProducto.req.producto = producto;

    await expectLater(
      crearProducto.exec(),
      completes,
    );

    // Verificamos que haya creado el registro de la version con todas sus propiedades
    final productoVersion =
        await consultas.obtenerVersionDeProducto(producto.versionActual);

    expect(productoVersion, isNotNull);
    expect(productoVersion!.codigo, producto.codigo);
  });

  test('debe lanzar una excepcion si el codigo existe', () async {
    var crearProducto = ModuloProductos.crearProducto();
    crearProducto.req.producto = llenarProductoConCodigo('12345-3323');

    // Lo creamos la primera vez, debe pasar
    await crearProducto.exec();

    // Al crearlo por segunda vez, debe tronar
    await expectLater(crearProducto.exec(), throwsA(isA<ValidationEx>()));
  });

  test('debe persistir el producto con categoria "sin categoria"', () async {
    var crearProducto = ModuloProductos.crearProducto();

    crearProducto.req.producto = llenarProductoConCodigo('S34gj4');
    crearProducto.req.producto.categoria = Categoria.cargar(
      uid: UID.invalid(),
      nombre: NombreCategoria.sinCategoria(),
      eliminado: false,
    );

    await expectLater(
      crearProducto.exec(),
      completes,
    );
  });
}
