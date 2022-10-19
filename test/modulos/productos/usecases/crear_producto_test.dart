import 'package:eleventa/modulos/common/utils/uid.dart';
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

  test('debe persistir el producto', () async {
    var crearProducto = ModuloProductos.crearProducto();

    print('\x1B[31mPRUEBA\x1B[0m');

    const codigo = '123456';
    const nombre = 'Atun tunny 200 grs.';
    const precioDeVenta = 13400000;
    const precioDeCompra = 10400000;

    var producto = Producto.crear(
        codigo: codigo,
        nombre: nombre,
        precioDeVenta: precioDeVenta,
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
}
