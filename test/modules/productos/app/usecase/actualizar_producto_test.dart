import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe actualizar el item si los parametros son correctos', () async {
    var actualizarProducto = ModuloProductos.actualizarProducto();
    var crearProducto = ModuloProductos.crearProducto();
    var obtenerProducto = ModuloProductos.obtenerProducto();

    const sku = '123456';
    const descripcion = 'Atun tunny 200 grs.';
    const precioActualizado = 13.40;

    crearProducto.req.sku = sku;
    crearProducto.req.descripcion = descripcion;
    crearProducto.req.precio = 10.50;

    var uid = await crearProducto.exec();

    actualizarProducto.req.producto.uid = uid.toString();
    actualizarProducto.req.producto.sku = sku;
    actualizarProducto.req.producto.descripcion = descripcion;
    actualizarProducto.req.producto.precio = precioActualizado;

    await actualizarProducto.exec();

    obtenerProducto.req.sku = sku;
    final item = await obtenerProducto.exec();

    expect(item.precio, precioActualizado);
  });
}
