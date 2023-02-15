import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe obtener la version especifica de producto al cargar una venta',
      () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    var crearProducto = ModuloProductos.crearProducto();
    var modificarProducto = ModuloProductos.modificarProducto();
    var consultas = ModuloVentas.repositorioConsultaVentas();
    var consultasProductos = ModuloProductos.repositorioConsultaProductos();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;

    await crearProducto.exec();

    Venta ventaEnProgreso = Venta.crear();

    var formasDisponibles = await consultas.obtenerFormasDePago();

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: Moneda(24411.00),
    );

    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    var nombreOriginal = producto.nombre;
    var nombreModificado = 'Otro nombre';
    var productoModificado =
        producto.copyWith(nombre: NombreProducto(nombreModificado));

    modificarProducto.req.producto = productoModificado;

    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    var versionDeProducto = await consultasProductos.obtenerVersionDeProducto(
      UID.fromString(ventaCobrada!.articulos.first.versionProductoUID),
    );

    expect(versionDeProducto!.nombre, nombreOriginal);
  });
}
