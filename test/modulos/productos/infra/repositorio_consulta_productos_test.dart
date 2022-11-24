import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
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
