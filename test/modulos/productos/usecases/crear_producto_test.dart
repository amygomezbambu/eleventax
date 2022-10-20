import 'package:eleventa/modulos/common/domain/moneda.dart';
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

    const codigo = '123456';
    const nombre = 'Atun tunny 200 grs.';
    final precioDeVenta = Moneda(13.40);
    final precioDeCompra = Moneda(10.40);

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
