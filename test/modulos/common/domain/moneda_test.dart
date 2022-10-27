import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // TODO: Implementar faker para simular distintos montos
  test('Debe convertir un monto decimal con centavos a formato MonedaInt', () {
    var moneda = Moneda(10.40);

    expect(moneda.toMonedaInt(), 10400000);
  });

  test('Debe convertir un monto decimal sin centavos a formato MonedaInt', () {
    var moneda = Moneda(10.00);

    expect(moneda.toMonedaInt(), 10000000);
  });

  test('Debe convertir un monto en String a formato MonedaInt', () {
    var moneda = Moneda('99.10');

    expect(moneda.toMonedaInt(), 99100000);
  });

  test('Debe convertir un monto entero a formato MonedaInt', () {
    var moneda = Moneda(1);

    expect(moneda.toMonedaInt(), 1000000);
  });

  test('Debe comparar dos valores de Moneda correctamente', () {
    var monedaInt = Moneda.fromMonedaInt(10000000);
    var monedaString = Moneda('10.00');

    expect(monedaInt, monedaString);
  });

  test('Debe de regresar excepcion si se le pasa un monto inválido', () {
    expect(() => Moneda([]), throwsA(isA<EleventaEx>()));
  });
}
