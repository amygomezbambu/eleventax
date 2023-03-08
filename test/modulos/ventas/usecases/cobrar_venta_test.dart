import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto_generico.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/productos/usecases/crear_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:eleventa/modulos/ventas/usecases/cobrar_venta.dart';
import 'package:eleventa/modulos/ventas/ventas_ex.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  late CobrarVenta cobrarVenta;
  late IRepositorioConsultaVentas consultas;
  late CrearProducto crearProducto;

  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();

    cobrarVenta = ModuloVentas.cobrarVenta();
    consultas = ModuloVentas.repositorioConsultaVentas();
    crearProducto = ModuloProductos.crearProducto();
  });

  Future<int> obtenerSiguienteFolio() async {
    final consultas = ModuloVentas.repositorioConsultaVentas();
    var folioActual = await consultas.obtenerFolioDeVentaMasReciente();
    var consecutivoInicial = 1000;
    if (folioActual != null) {
      int consecutivo = int.parse(folioActual.split('-')[1]);
      consecutivo++;
      consecutivoInicial = consecutivo;
    }

    return consecutivoInicial;
  }

  test('debe almacenar los datos de la venta al registrar el cobro', () async {
    final consultasProductos = ModuloProductos.repositorioConsultaProductos();

    Venta ventaEnProgreso = Venta.crear();

    var cantidad = 1.00;
    var cantidadGranel = 0.545;

    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var productoGranel = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      productoSeVendePor: ProductoSeVendePor.peso,
    );

    crearProducto.req.producto = productoGranel;
    await crearProducto.exec();

    var formasDisponibles = await consultas.obtenerFormasDePago();
    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var articuloGranel =
        Articulo.crear(producto: productoGranel, cantidad: cantidadGranel);

    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarArticulo(articuloGranel);

    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: ventaEnProgreso.total,
    );
    ventaEnProgreso.agregarPago(pago);

    final siguienteFolioEsperado = await obtenerSiguienteFolio();

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    // TODO: Ver cómo comparar la fecha/hora de cobro
    // date1.isAtSameMomentAs(date2) returns bool.
    /* date1.compareTo(date2),
       a negative value if this DateTime isBefore other.
       0 if this DateTime isAtSameMomentAs other, and
       a positive value otherwise (when this DateTime isAfter other)
     */
    expect(ventaCobrada, isNotNull);
    expect(ventaCobrada!.cobradaEn, isNotNull);
    expect(ventaCobrada.subtotal, ventaEnProgreso.subtotal);
    expect(ventaCobrada.totalImpuestos, ventaEnProgreso.totalImpuestos);
    expect(ventaCobrada.total, ventaEnProgreso.total);
    expect(ventaCobrada.estado, EstadoDeVenta.cobrada);

    expect(ventaCobrada.folio, 'A-$siguienteFolioEsperado',
        reason: 'Debe asignar un prefijo y folio por defecto');

    expect(ventaCobrada.pagos.length, 1,
        reason: 'Debe registrar la forma de pago');

    expect(
      ventaCobrada.articulos.length,
      ventaEnProgreso.articulos.length,
      reason:
          'Los articulos cobrados no fueron los mismos que la venta en progreso',
    );

    var version = ventaCobrada.articulos.first.versionProductoUID;

    var versionDeProducto =
        consultasProductos.obtenerVersionDeProducto(UID.fromString(version));

    expect(versionDeProducto, isNotNull);

    var ventaEnProgresoDb =
        await consultas.obtenerVentaEnProgreso(ventaEnProgreso.uid);

    expect(
      ventaEnProgresoDb,
      isNull,
      reason: 'La venta en progreso no fue eliminada despues del cobro',
    );
  });

  test('debe almacenar una venta con productos genericos', () async {
    final cobrarVenta = ModuloVentas.cobrarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final consultasProductos = ModuloProductos.repositorioConsultaProductos();
    final listaImpuestos = await consultasProductos.obtenerImpuestos();
    final formasDisponibles = await consultas.obtenerFormasDePago();

    Venta ventaEnProgreso = Venta.crear();

    var cantidad = 1.00;

    var precioVenta = 24411.00;

    final productoGenerico = ProductoGenerico.crear(
      nombre: NombreProducto('Chicles'),
      precioDeVenta: PrecioDeVentaProducto(Moneda(precioVenta)),
      impuestos: [listaImpuestos.first],
    );

    var articuloGenerico =
        Articulo.crear(producto: productoGenerico, cantidad: cantidad);

    ventaEnProgreso.agregarArticulo(articuloGenerico);

    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: ventaEnProgreso.total,
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    expect(ventaCobrada, isNotNull);

    var articuloCobrado = ventaCobrada!.articulos.first;

    expect(ventaCobrada.articulos.length, 1);
    expect(articuloCobrado, isNotNull);
    expect(articuloCobrado.esGenerico, true);
    expect(articuloCobrado.productoNombre, productoGenerico.nombre);
    expect(articuloCobrado.totalesDeImpuestos.length, 1);
    expect(articuloCobrado.totalesDeImpuestos.first.nombreImpuesto,
        listaImpuestos.first.nombre);
    expect(articuloCobrado.totalesDeImpuestos.first.porcentaje,
        listaImpuestos.first.porcentaje.redondearADecimales(2).toDouble());
  });

  test('debe incrementar el folio de venta tras cada cobro', () async {
    final cobrarVenta = ModuloVentas.cobrarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final formasDisponibles = await consultas.obtenerFormasDePago();
    final crearProducto = ModuloProductos.crearProducto();

    const precio = 11.55;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precio),
      precioVenta: Moneda(precio),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    // Como la prueba puede ejecutarse en cualquier orden pueden o no existir ventas previas
    // verificamos
    final consecutivoInicial = await obtenerSiguienteFolio();

    for (var i = 0; i < 10; i++) {
      Venta ventaEnProgreso = Venta.crear();
      var articulo = Articulo.crear(
        producto: producto,
        cantidad: 1.0,
      );
      var pago = Pago.crear(
        forma: formasDisponibles.first,
        monto: Moneda(precio),
      );

      ventaEnProgreso.agregarArticulo(articulo);
      ventaEnProgreso.agregarPago(pago);

      cobrarVenta.req.venta = ventaEnProgreso;
      await cobrarVenta.exec();

      // Verificamos que el folio se incremente
      VentaDto? ventaCobrada =
          await consultas.obtenerVenta(ventaEnProgreso.uid);
      expect(ventaCobrada!.folio, 'A-${consecutivoInicial + i}',
          reason: 'Debe incrementar el folio de la venta $i');
    }
  });

  test('debe lanzar error si las formas de pago exceden el total de la venta',
      () async {
    Venta ventaEnProgreso = Venta.crear();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var formasDisponibles = await consultas.obtenerFormasDePago();
    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: Moneda(24407.00),
    );

    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;

    TiposVentasEx? tipoEx;

    try {
      await cobrarVenta.exec();
    } catch (e) {
      if (e is VentasEx) {
        tipoEx = e.tipo;
      }
    }

    expect(tipoEx, TiposVentasEx.pagosInsuficientes);
  });

  test('debe lanzar error si total a dos decimales es cero', () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    //var consultas = ModuloVentas.repositorioConsultaVentas();

    Venta ventaEnProgreso = Venta.crear();

    var cantidad = 0.001;
    var precioVenta = 1.00;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioVenta),
      precioVenta: Moneda(precioVenta),
      productoSeVendePor: ProductoSeVendePor.peso,
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);
    cobrarVenta.req.venta = ventaEnProgreso;

    TipoValidationEx? tipoEx;

    try {
      await cobrarVenta.exec();
    } catch (e) {
      if (e is ValidationEx) {
        tipoEx = e.tipo;
      }
    }

    expect(tipoEx, TipoValidationEx.valorEnCero);
  });
}
