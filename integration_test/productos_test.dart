import 'dart:io';

import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:eleventa/modulos/productos/ui/vista_listado_productos.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eleventa/main.dart' as app;

void main() {
  var binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vista de productos', () {
    final faker = Faker();

    testWidgets('debe de crear y modificar producto correctamente',
        (tester) async {
      WidgetController.hitTestWarningShouldBeFatal = true;

      if (Platform.isWindows || Platform.isMacOS) {
        await binding.setSurfaceSize(const Size(400, 600));
        binding.window.physicalSizeTestValue = const Size(400, 600);
        binding.window.devicePixelRatioTestValue = 1.0;
      }

      // Almacenamos el manejador onError que trae el integration_test framework
      // ya que nosotros lo re-asignamos
      final originalOnError = FlutterError.onError!;
      //final originalErrorBuilder = ErrorWidget.builder;

      await app.main();

      FlutterError.onError = (FlutterErrorDetails details) {
        // Mandamos llamar la funcion onError para mostrar errores
        // de las pruebas
        originalOnError(details);
      };

      await tester.pumpAndSettle();

      binding.testTextInput.register();

      var boton = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Productos'),
      );

      await tester.tap(boton);
      await tester.pumpAndSettle();

      var botonCrearProducto = find.byKey(VistaListadoProductos.keyBotonCobrar);
      await tester.tap(botonCrearProducto);
      await tester.pumpAndSettle();

      final String productoCodigo =
          faker.randomGenerator.integer(99999999).toString();
      final nombreProductoEsperado = '🍅 Tomate Por Unidad $productoCodigo';
      const precioProductoEsperado = '30.5085';

      var tituloVista = find.descendant(
          of: find.byType(AppBar), matching: find.text('Nuevo Producto'));

      expect(tituloVista, findsOneWidget,
          reason: 'Debe tener el titulo de la vista de Nuevo Producto');

      await tester.enterText(
          find.byKey(FormaProducto.txtCodigo), productoCodigo);

      await tester.enterText(
          find.byKey(FormaProducto.txtNombre), nombreProductoEsperado);

      await tester.tap(find.byKey(FormaProducto.cbxCategoria));
      await tester.pumpAndSettle();

      final dropdownItem = find.text('Frutas').last;

      await tester.tap(dropdownItem);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(FormaProducto.rdbSeVendePorPeso));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(FormaProducto.cbxUnidadMedida));

      await tester.pumpAndSettle();
      final dropdownItemUnidadDeMedida = find.text('Pieza').last;

      await tester.tap(dropdownItemUnidadDeMedida);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(FormaProducto.cbxImpuestos));

      await tester.pumpAndSettle();
      final dropdownImpuestos = find.text('IVA 0%').last;

      await tester.tap(dropdownImpuestos);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(FormaProducto.txtPrecioCompra), '29.4507');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(FormaProducto.txtPrecioVenta), precioProductoEsperado);
      await tester.pumpAndSettle();

      final botonGuardar = find.byKey(FormaProducto.btnGuardar);
      await tester.dragUntilVisible(
          botonGuardar, find.byType(FormaProducto), const Offset(0, 500));

      await tester.tap(botonGuardar, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));

      final productoListItem =
          find.widgetWithText(ListTile, nombreProductoEsperado);

      expect(
        productoListItem,
        findsOneWidget,
        reason:
            'Debe existir el nuevo producto en el listado con el nombre correcto',
      );

      //Modificar producto...
      await tester.tap(productoListItem, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      final nombreNuevo = 'Pepsi 1lt $productoCodigo';
      const nuevoPrecioVenta = '31.0795';

      var textInput = find.byKey(FormaProducto.txtNombre);
      await tester.pumpAndSettle();
      await tester.tap(textInput);
      await tester.pumpAndSettle();
      await tester.enterText(textInput, nombreNuevo);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(FormaProducto.txtPrecioVenta), nuevoPrecioVenta);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
          botonGuardar, find.byType(FormaProducto), const Offset(0, 500));

      await Future.delayed(const Duration(seconds: 4));
      await tester.tap(botonGuardar, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));

      var nuevoItemNombre = find.widgetWithText(ListTile, nombreNuevo);
      expect(
        nuevoItemNombre,
        findsOneWidget,
        reason:
            'Debe existir el producto modificado en el listado con el nombre correcto',
      );

      expect(
        find.widgetWithText(ListTile, Moneda(nuevoPrecioVenta).toString()),
        findsOneWidget,
        reason:
            'Debe existir el producto modificado en el listado con el precio de venta correcto',
      );

      await tester.tap(nuevoItemNombre);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Eliminar producto'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(ListTile, nombreNuevo),
        findsNothing,
        reason: 'La lista debio estar vacia despues de eliminar producto.',
      );

      // await Future.delayed(const Duration(seconds: 4));
    });
  });
}
