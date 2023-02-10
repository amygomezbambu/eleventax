import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe guardar la venta en progreso en la base de datos si no esta vacia',
      () async {
    final guardar = ModuloVentas.guardarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();

    guardar.req.venta = Venta.crear();
    final uid = guardar.req.venta.uid;

    await guardar.exec();

    final venta = consultas.obtenerVenta(uid);

    expect(venta, isNotNull);
    //TODO: validar que tenga TODOS los datos que guardamos
  });
}
