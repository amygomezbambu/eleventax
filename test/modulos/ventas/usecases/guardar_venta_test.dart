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
    //Necesito la venta

    final guardar = ModuloVentas.guardarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();

    guardar.req.venta = Venta.crear(); //Llenar los datos //estado = enProgreso;
    final uid = guardar.req.venta.uid;

    await guardar.exec();

    //leerlo de la db
    final venta = consultas.obtenerVenta(uid);

    expect(venta, isNotNull);
    //expect() validar que tenga todos los datos que guardamos
  });
}
