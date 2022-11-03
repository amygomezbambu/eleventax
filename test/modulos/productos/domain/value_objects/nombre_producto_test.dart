import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debe aceptar un nombre con emojis', () {
    var nombreEsperado = 'Vamos a La Playa 🏖️';

    var nombre = NombreProducto(nombreEsperado);

    expect(nombre.value, nombreEsperado);
  });

  test('Debe limpiar caracteres invisibles', () {
    var nombreEsperado = 'Nombre Valido';

    var nombre = NombreProducto('$nombreEsperado‎');

    expect(nombre.value, nombreEsperado);
  });

  test('Debe remover el exceso de espacios', () {
    var prefijo = 'Nombre';
    var posfijo = 'Valido';

    var nombre = NombreProducto('   $prefijo ‎ $posfijo  ');

    expect(nombre.value, '$prefijo $posfijo');
  });

  test('Debe convertir el nombre a Title Case', () {
    var esperado = 'Sopa Nissin 20mg';

    var nombreEnMinusculas = NombreProducto(esperado.toLowerCase());
    expect(nombreEnMinusculas.value, esperado);

    var nombreEnMayusculas = NombreProducto(esperado.toUpperCase());
    expect(nombreEnMayusculas.value, esperado);
  });

  test('Debe lanzar excepción si el nombre es vacio', () {
    expect(() => NombreProducto(''), throwsA(isA<DomainEx>()));
  });

  test('Debe lanzar excepción si la longitud es mayor a 130', () {
    var nombreMuyLargo = '''
        El nombre de producto permite números, letras o símbolos con un máximo de 130 caracteres
        El nombre de producto permite números, letras o símbolos con un máximo de 130 caracteres
        El nombre de producto permite números, letras o símbolos con un máximo de 130 caracteres
        ''';
    expect(() => NombreProducto(nombreMuyLargo), throwsA(isA<DomainEx>()));
  });
}
