import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe lanzar excepcion si el precio es cero o negativo', () {
    for (var numero in <num>[0, -12, 0.0, -0.54, -75.99]) {
      if (numero is int) {
        expect(
          () => PrecioDeVentaProducto(Moneda(numero)),
          throwsA(isA<ValidationEx>()),
          reason:
              'Debe lanzar una excepción si el precio de venta es negativo o cero',
        );
      } else {
        expect(
          () => PrecioDeVentaProducto(Moneda(numero as double)),
          throwsA(isA<ValidationEx>()),
          reason:
              'Debe lanzar una excepción si el precio de venta es negativo o cero',
        );
      }
    }
  });
}
