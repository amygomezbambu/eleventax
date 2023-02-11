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
    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var producto = Producto.crear(
        codigo: CodigoProducto('2343Q34'),
        nombre: NombreProducto(nombre),
        precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
        precioDeVenta: PrecioDeVentaProducto.sinPrecio(),
        unidadDeMedida: UnidadDeMedida.crear(
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
