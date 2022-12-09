import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test(
      'debe lanzar excepcion si el precio es negativo, o si la configuración no permite cero',
      () {
    ModuloProductos.config.compartida.permitirPrecioCompraCero = true;

    for (var numero in <Object>[-12, -0.54, -75.99, '-35']) {
      expect(
        () => PrecioDeCompraProducto(Moneda(numero)),
        throwsA(isA<ValidationEx>()),
        reason: 'Debe lanzar una excepción si el precio de venta es negativo',
      );
    }

    for (var numero in <Object>[0, 0.0, '0.0']) {
      expect(
        PrecioDeCompraProducto(Moneda(numero)).value,
        Moneda(numero),
        reason: 'Debe permitir cero si la configuración lo perimite',
      );
    }

    ModuloProductos.config.compartida.permitirPrecioCompraCero = false;

    for (var numero in <Object>[0, 0.0, '0.0']) {
      expect(
        () => PrecioDeCompraProducto(Moneda(numero)),
        throwsA(isA<ValidationEx>()),
        reason:
            'Debe lanzar una excepción si la configuración no permite precio cero',
      );
    }
  });
}
