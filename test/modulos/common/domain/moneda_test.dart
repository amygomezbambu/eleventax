import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final faker = Faker();
  //al hacer operaciones , suma, resta entre monedas , el resultado sea correcto
  //que este redondeado a moneda.digitosDecimales

  test('Debe convertir enteros, decimales y cadenas correctas a moneda', () {
    for (var element in <Object>[
      '0.0',
      0,
      0.0,
      27,
      38.85758,
      2373637,
      '1234.384784'
    ]) {
      expect(() => Moneda(element), returnsNormally);
    }

    const decimal = 38.85758898;
    final moneda = Moneda(decimal);

    expect(
      moneda.toString(),
      decimal.toStringAsFixed(appConfig.decimalesAMostrar),
    );
  });

  test('Debe realizar operaciones matematicas de manera correcta', () {});

  test('Debe convertir un monto en String a formato MonedaInt', () {
    final decimal = faker.randomGenerator.decimal();
    var moneda = Moneda(decimal.toString());
    var moneda2 = Moneda(decimal);

    expect(moneda.serialize(), moneda2.serialize());
  });

  test('Debe comparar dos valores de Moneda correctamente', () {
    final valoresEnteros = <int>[];
    final valoresDecimales = <double>[];

    for (var i = 0; i < 10; i++) {
      valoresEnteros.add(faker.randomGenerator.integer(10000));
      valoresDecimales.add(faker.randomGenerator.decimal());
    }

    for (var entero in valoresEnteros) {
      var monedaInt = Moneda(entero);
      var monedaString = Moneda(entero.toString());

      expect(monedaInt, monedaString);
    }

    for (var decimal in valoresDecimales) {
      var moneda = Moneda(decimal);
      var monedaString = Moneda(decimal.toString());

      expect(moneda, monedaString);
    }
  });

  test('Debe de regresar excepcion si se le pasa un monto inválido', () {
    expect(() => Moneda([]), throwsA(isA<EleventaEx>()));
  });

  test('Debe convertir a importeCobrable de forma correcta', () {
    expect(Moneda(1.025).montoInterno, 1025000,
        reason: 'No esta convirtiendo correctamente fromDouble');
    expect(Moneda(1.025).importeCobrable.montoInterno, 1030000);

    expect(Moneda(1.025).importeCobrable.toString(), '1.03');
    expect(Moneda(6.425).importeCobrable.toString(), '6.43');
    expect(Moneda(79.614).importeCobrable.toString(), '79.61');
    expect(Moneda(79.615).importeCobrable.toString(), '79.62');
    expect(Moneda(79.616).importeCobrable.toString(), '79.62');
    expect(Moneda(1.235).importeCobrable.toString(), '1.24');
    expect(Moneda(9.645).importeCobrable.toString(), '9.65');
  });
}
