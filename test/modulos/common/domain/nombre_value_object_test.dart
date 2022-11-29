import 'package:eleventa/modulos/common/domain/nombre_value_object.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debe lanzar excepcion si el nombre tiene longitud inválida', () async {
    const longitudMaxima = 200;
    expect(
      () => NombreValueObject(
          nombre: ('a' * (longitudMaxima + 1)), longitudMaxima: longitudMaxima),
      throwsA(isA<DomainEx>()),
    );
  });

  test('debe lanzar excepcion si el nombre es vacío', () async {
    expect(
      () => NombreValueObject(nombre: ''),
      throwsA(isA<DomainEx>()),
    );
  });

  test('debe crear un nombre con datos válidos', () async {
    const cadenaNombre = 'Prueba';
    var nombreEsperado = NombreValueObject(nombre: cadenaNombre);
    expect(cadenaNombre, nombreEsperado.value);
  });
}
