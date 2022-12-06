import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eleventa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke Test', () {
    testWidgets(
        'debe mostrar los botones de navegación de las vistas principales y cambiar las vistas de forma correspondiente',
        (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      for (var element in ['Ventas', 'Productos']) {
        var boton = find.descendant(
            of: find.byType(BottomNavigationBar), matching: find.text(element));

        expect(boton, findsOneWidget,
            reason:
                'No existió el botón de $element en la barra de navegación');

        // Damos tap al botón para entrar a la vista principal
        await tester.tap(boton);
        await tester.pumpAndSettle();

        var tituloVista = find.descendant(
            of: find.byType(AppBar), matching: find.text(element));

        expect(tituloVista, findsOneWidget,
            reason: 'No existió el título de la Vista Principal de $element');
      }
    });
  });
}
