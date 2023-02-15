import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe persistir la venta en progreso si no esta vacia', () async {
    final guardar = ModuloVentas.guardarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final crearProducto = ModuloProductos.crearProducto();

    final consultasProductos = ModuloProductos.repositorioConsultaProductos();
    final unidadesMedida = await consultasProductos.obtenerUnidadesDeMedida();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var venta = Venta.crear();
    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      unidadDeMedida: unidadesMedida.first,
      impuestos: [],
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var articulo1 = Articulo.crear(producto: producto, cantidad: cantidad);
    venta.agregarArticulo(articulo1);

    guardar.req.venta = venta;
    await guardar.exec();

    final ventaDb = await consultas.obtenerVentaEnProgreso(venta.uid);

    expect(ventaDb, isNotNull, reason: 'la venta obtenida no debe ser nula');
    expect(
        ventaDb!.articulos
            .firstWhere((element) => element.uid == articulo1.uid),
        isNotNull,
        reason: 'la venta obtenida debe contener el artículo agregado');
    expect(ventaDb.total, isNot(Moneda(0)),
        reason: 'el total de la venta obtenida no debe ser cero');
    expect(ventaDb.subtotal != Moneda(0), true,
        reason: 'el subtotal de la venta obtenida no debe ser cero');
    //TODO: validar que tenga TODOS los datos que guardamos
  });
}
