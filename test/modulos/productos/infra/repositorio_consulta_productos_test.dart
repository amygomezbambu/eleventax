import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe de obtener un producto activo', () async {
    var crearProducto = ModuloProductos.crearProducto();
    var repo = ModuloProductos.repositorioConsultaProductos();

    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var unidadesMedida = await repo.obtenerUnidadesDeMedida();

    var productoCreado = Producto.crear(
        codigo: CodigoProducto('12343434343'),
        nombre: NombreProducto(nombre),
        precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
        precioDeVenta: PrecioDeVentaProducto(precioDeCompra),
        unidadDeMedida: unidadesMedida.first);

    crearProducto.req.producto = productoCreado;

    await crearProducto.exec();

    var productoEsperado = repo.obtenerProducto(productoCreado.uid);
    expect(productoEsperado, isNotNull,
        reason: 'El producto recien creado se debió haber obtenido');
  });

  test(
      'debe asignar categoria nula para aquellos productos con categoria borrada',
      () async {
    var repo = ModuloProductos.repositorioConsultaProductos();
    var unidadesMedida = await repo.obtenerUnidadesDeMedida();
    var categorias = await repo.obtenerCategorias();

    var crearProducto = ModuloProductos.crearProducto();

    var productoCreado = Producto.crear(
        codigo: CodigoProducto('123456AAAABB'),
        nombre: NombreProducto('Producto con categoria borrada'),
        precioDeCompra: PrecioDeCompraProducto(Moneda(11.42)),
        precioDeVenta: PrecioDeVentaProducto(Moneda(11.50)),
        unidadDeMedida: unidadesMedida.first,
        impuestos: [],
        categoria: categorias.first);

    crearProducto.req.producto = productoCreado;

    await crearProducto.exec();

    var eliminarCategoria = ModuloProductos.eliminarCategoria();
    eliminarCategoria.req.uidCategoria = categorias.first.uid;
    await eliminarCategoria.exec();

    var productoEsperado = await repo.obtenerProducto(productoCreado.uid);

    expect(productoEsperado!.categoria, isNull,
        reason: 'La categoria del producto que fue eliminada debe ser nula');
  });

  test('debe obtener las categorias activas', () async {
    final crearCategoria = ModuloProductos.crearCategoria();
    final eliminarCategoria = ModuloProductos.eliminarCategoria();
    final consultas = ModuloProductos.repositorioConsultaProductos();

    final categoria = Categoria.crear(nombre: NombreCategoria('Abarrotes'));

    crearCategoria.req.categoria = categoria;

    await crearCategoria.exec();

    eliminarCategoria.req.uidCategoria = categoria.uid;
    await eliminarCategoria.exec();

    final categorias = await consultas.obtenerCategorias();

    final countCategoriasEliminadas = categorias.where((cat) => cat.eliminado);

    expect(countCategoriasEliminadas.length, 0,
        reason: 'No se deben obtener las categorias eliminadas');
  });

  test('debe de obtener un producto solo con sus impuestos activos', () async {
    var repo = ModuloProductos.repositorioConsultaProductos();

    var crearProducto = ModuloProductos.crearProducto();
    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var impuestosActivos = await repo.obtenerImpuestos();
    var unidadesMedida = await repo.obtenerUnidadesDeMedida();

    var productoCreado = Producto.crear(
      codigo: CodigoProducto('TOMATE'),
      nombre: NombreProducto(nombre),
      precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
      precioDeVenta: PrecioDeVentaProducto(precioDeCompra),
      impuestos: [impuestosActivos.first],
      unidadDeMedida: unidadesMedida.first,
    );

    crearProducto.req.producto = productoCreado;

    var impuestosProductoModificado = [
      impuestosActivos[1],
      impuestosActivos[2]
    ];

    await crearProducto.exec();
    var productoModificado =
        productoCreado.copyWith(impuestos: impuestosProductoModificado);
    var modificarProducto = ModuloProductos.modificarProducto();
    modificarProducto.req.producto = productoModificado;
    await modificarProducto.exec();

    var productoEsperado = await repo.obtenerProducto(productoCreado.uid);
    expect(
      productoEsperado!.impuestos.length,
      impuestosProductoModificado.length,
      reason: 'El producto modificado solo debe contener un impuesto',
    );

    expect(
      setEquals(
        productoEsperado.impuestos.toSet(),
        impuestosProductoModificado.toSet(),
      ),
      true,
      reason: 'La lista de impuestos del producto no es la esperada',
    );
  });
}
