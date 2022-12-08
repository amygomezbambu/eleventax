import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:eleventa/modulos/productos/ui/vista_listado_productos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eleventa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Productos Test', () {
    testWidgets('debe de crear producto de venta por unidad', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // final originalOnError = FlutterError.onError!;
      // FlutterError.onError = (FlutterErrorDetails details) {
      //   // do something like ignoring an exception
      //   originalOnError(details); // call test framework's error handler
      // };

      var boton = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Productos'),
      );

      await tester.tap(boton);
      await tester.pumpAndSettle();

      var botonCrearProducto = find.byKey(VistaListadoProductos.keyBotonCobrar);
      await tester.tap(botonCrearProducto);
      await tester.pumpAndSettle();

      const nombreProductoEsperado = '🍅 Tomate Por Unidad';
      const precioProductoEsperado = '30.5085';

      var tituloVista = find.descendant(
          of: find.byType(AppBar), matching: find.text('Nuevo Producto'));

      expect(tituloVista, findsOneWidget,
          reason: 'Debe tener el titulo de la vista de Nuevo Producto');

      await tester.enterText(find.byKey(FormaProducto.keyCodigo), '12345texto');
      await tester.enterText(
          find.byKey(FormaProducto.keyNombre), nombreProductoEsperado);

      await tester.tap(find.byKey(FormaProducto.keyCategoria));
      await tester.pumpAndSettle();

      final dropdownItem = find.text('Frutas').last;

      await tester.tap(dropdownItem);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(FormaProducto.keySeVendePorPeso));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(FormaProducto.keyUnidadDeMedida));

      await tester.pumpAndSettle();
      final dropdownItemUnidadDeMedida = find.text('Pieza').last;

      await tester.tap(dropdownItemUnidadDeMedida);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(FormaProducto.keyImpuestos));

      await tester.pumpAndSettle();
      final dropdownImpuestos = find.text('IVA 0%').last;

      await tester.tap(dropdownImpuestos);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(FormaProducto.keyPrecioCompra), '29.4507');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(FormaProducto.keyPrecioVenta), precioProductoEsperado);
      await tester.pumpAndSettle();

      ScrollController scroller = FormaProducto.scrollController;
      scroller.jumpTo(500);
      await tester.pumpAndSettle();

      final botonGuardar = find.byKey(FormaProducto.keyBotonGuardar);

      await tester.tap(botonGuardar, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byTooltip('Regresar'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ListTile, nombreProductoEsperado),
        findsOneWidget,
        reason:
            'Debe existir el nuevo producto en el listado con el nombre correcto',
      );

      await Future.delayed(const Duration(seconds: 4));
    });
  });
}
