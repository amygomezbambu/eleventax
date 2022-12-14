import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe regresar un código si proporcionamos caracteres válidos', () {
    for (var element in [
      '12345 6789 10',
      '12345-6789-10',
      '@TEST@',
      '**te***',
      '\$aaaa\$',
      'M&Ms',
      'algo:sss',
      '14"',
      '1/2kg',
      'TEQUILAAÑEJO',
      'Café',
      'Añejo',
      'agüita amarilla',
      '🍅Tomate bola'
    ]) {
      var codigo = CodigoProducto(element);
      expect(codigo.value, element.toUpperCase());
    }
  });

  test('Debe lanzar excepcion cuando longitud sea incorrecta', () {
    expect(() => CodigoProducto('1234567890123456789111111111'),
        throwsA(isA<ValidationEx>()));
  });

  test('Debe lanzar excepcion cuando sea vacio', () {
    expect(() => CodigoProducto(''), throwsA(isA<ValidationEx>()));
  });

  test('Debe lanzar excepcion cuando el codigo sea reservado (Venta Rapida)',
      () {
    expect(() => CodigoProducto('0'), throwsA(isA<ValidationEx>()));
  });

  test('Debe remover los espacios al principio y al final', () {
    var codigoEsperado = '  12345678    ';
    var codigo = CodigoProducto(codigoEsperado);

    expect(codigo.value, codigoEsperado.trim());
  });

  test('Debe convertir a Mayúsculas el codigo', () {
    var codigoEsperado = 'enminusculas';
    var codigo = CodigoProducto(codigoEsperado);

    expect(codigo.value, codigoEsperado.toUpperCase());
  });

  test('Debe eliminar caracteres invisibles de un codigo', () {
    var valorEsperado = 'CORRECTO';
    var codigo = CodigoProducto('$valorEsperado‎');

    expect(codigo.value, valorEsperado);
  });
}
