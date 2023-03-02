import 'dart:io';

import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/boton_cobrar.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:eleventa/main.dart' as app;

import '../test/utils/productos.dart';

void main() {
  var binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final faker = Faker();
  var codigoProducto = '';

  Future<void> setup() async {
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

    await binding.setLocale('es', 'MX');

    // Agregamos esta linea para que funcione las llamadas a enterText en dispositivos reales
    // Ref: https://github.com/flutter/flutter/issues/87990#issuecomment-1003675826
    binding.testTextInput.register();
  }

  Future<void> crearProductosParaPrueba() async {
    codigoProducto = faker.randomGenerator.numberOfLength(10).toString();

    final crearProducto = ModuloProductos.crearProducto();
    final prod1 =
        ProductosUtils.crearProducto(codigo: codigoProducto, nombre: 'uno');

    crearProducto.req.producto = prod1;
    await crearProducto.exec();
  }

  group('Vista de ventas', () {
    testWidgets('Venta en progreso - desktop', (tester) async {
      WidgetController.hitTestWarningShouldBeFatal = true;

      await setup();
      await tester.pumpAndSettle();

      // SQLiteFlow, 12345
      try {
        await crearProductosParaPrueba();
      } catch (e) {
        print('No se pudoc rear producto: $e');
      }

      // var boton = find.descendant(
      //   of: find.byType(NavigationRailDestination),
      //   matching: find.text('Ventas'),
      // );
      // expect(boton, findsOneWidget);

      // await tester.tap(boton);
      // await tester.pumpAndSettle();

      // 1.1 - Al entrar por primera vez al módulo de ventas se muestra una
      // vista con la venta actual en curso la cual no tiene ningún artículo y
      //el total a cobrar es de cero.
      expect(find.widgetWithText(BotonCobrarVenta, '\$0.0'), findsOneWidget);
      expect(find.byType(BotonCobrarVenta), findsOneWidget);

      // TODO: Verificar que NO exista el listado de productos (ListView)

      // 1.3 - Existe un campo dentro de la interfase para que el usuario pueda ingresar o escanear un código de producto manualmente.
      var campoCodigo = find.byKey(VistaVentas.keyCampoCodigo);
      expect(campoCodigo, findsOneWidget);

      // TODO: Verificar que se mande ENTER despues del codigo para que se agregue a la venta
      await tester.enterText(campoCodigo, codigoProducto);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // TODO: Verificar que SI exista el listado, y tenga 1 articulo

      await tester.pump(const Duration(seconds: 5));

      expect(find.text('uno'), findsOneWidget);

      // corroborar que se agregue al listado, se actualice, total, etc.
    });
  }, skip: (Platform.isAndroid || Platform.isIOS));
}
