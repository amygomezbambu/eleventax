import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe regresar un código si proporcionamos caracteres válidos', () {
    var codigoEsperado = '12345 6789 10';
    var codigo = CodigoProducto(codigoEsperado);

    expect(codigo.value, codigoEsperado);
  });

  test('debe regresar código valido si proporcionamos codigo con guiones', () {
    var codigoEsperado = '12345-6789-10';
    var codigo = CodigoProducto(codigoEsperado);

    expect(codigo.value, codigoEsperado);
  });

  test('Debe lanzar excepcion cuando longitud sea incorrecta', () {
    expect(() => CodigoProducto('1234567890123456789111111111'),
        throwsA(isA<DomainEx>()));
  });

  test('Debe lanzar excepcion cuando sea vacio', () {
    expect(() => CodigoProducto(''), throwsA(isA<DomainEx>()));
  });

  test('Debe lanzar excepcion cuando tengamos caracteres especiales: simbolos',
      () {
    expect(() => CodigoProducto('&'), throwsA(isA<DomainEx>()));
  });

  test('Debe lanzar excepcion cuando el codigo sea reservado (Venta Rapida)',
      () {
    expect(() => CodigoProducto('0'), throwsA(isA<DomainEx>()));
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
