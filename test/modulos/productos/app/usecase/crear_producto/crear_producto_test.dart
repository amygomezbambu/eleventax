import 'package:eleventa/modulos/productos/domain/entity/producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe persistir el producto', () async {
    var crearProducto = ModuloProductos.crearProducto();

    const codigo = '123456';
    const nombre = 'Atun tunny 200 grs.';
    const precioDeVenta = 13.40;
    const precioDeCompra = 10.0;

    var producto = Producto.crear(
        codigo: codigo,
        nombre: nombre,
        precioDeVenta: precioDeVenta,
        precioDeCompra: precioDeCompra);

    crearProducto.req.producto = producto;

    await expectLater(
      crearProducto.exec(),
      completes,
    );

    //expect(item.precio, precioActualizado);
  });
}
