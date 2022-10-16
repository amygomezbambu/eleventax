import 'package:eleventa/loader.dart';
import 'package:eleventa/modulos/common/ui/widgets/boton_primario.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eleventa/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Definimos los keys que se usa en comun dentro de la prueba del módulo
  const payButtonKey = ValueKey('payButton');
  const skuFieldKey = ValueKey('skuField');

  // Agregamos esta linea para que funcione las llamadas a enterText en dispositivos reales
  // Ref: https://github.com/flutter/flutter/issues/87990#issuecomment-1003675826
  binding.testTextInput.register();

  group('Agregar articulos a venta', () {
    setUpAll(() async {
      var loader = Loader();
      await loader.iniciar();
    });

    testWidgets('Verificar que exista botón de cobrar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.EleventaApp());
      await tester.pumpAndSettle();

      expect(find.byKey(payButtonKey), findsWidgets);
    });

    testWidgets(
        'Agregar articulo y el boton de cobrar refleje total actualizado',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.EleventaApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(skuFieldKey), '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verificamos que el botón de cobrar tenga el total actualizado
      expect(
          find.widgetWithText(BotonPrimario, 'Cobrar \$10.33'), findsOneWidget,
          reason: 'No se actualizo el total de la venta');

      await tester.tap(find.byKey(payButtonKey));
      await tester.pumpAndSettle();
      debugPrint('Se termino segunda prueba!');
    });

    testWidgets('Agregar articulo el total se actualice',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.EleventaApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(skuFieldKey), '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Enumerate all states that exist in the app just to show we can
      // debugPrint("All states: ");
      // for (var s in tester.allStates) {
      //   debugPrint(s.toString());
      // }

      // Accedemos al estado de la vista de Ventas
      // para poder consultar los valores nativos
      final state = tester.state<VentaActualState>(find.byType(VentaActual));

      // Verificamos que la venta se haya actualizado consultando
      // el estado del Widget de ventas
      debugPrint(state.saleTotal.toString());
      expect(state.saleTotal, equals(10.33),
          reason: 'El total de la venta no se actualizo');

      await tester.tap(find.byKey(payButtonKey));
      await tester.pumpAndSettle();
    });
  });
}
