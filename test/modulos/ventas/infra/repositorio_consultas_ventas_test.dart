import 'dart:js_interop';

import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
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

  test('Debe obtener el listado de ventas cobradas en el dia actual', () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloVentas.repositorioConsultaVentas();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var producto = ProductosUtils.crearProducto(
      codigo: 'COKE600',
      nombre: 'Coca cola 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var formasDisponibles = await consultas.obtenerFormasDePago();

    var pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: Moneda(24411.00),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    Venta ventaEnProgreso = Venta.crear();
    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    ventaEnProgreso = Venta.crear();
    ventaEnProgreso.agregarArticulo(articulo);
    ventaEnProgreso.agregarArticulo(articulo);

    pago = Pago.crear(
      forma: formasDisponibles.first,
      monto: Moneda(48822.00),
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    var ventasCobradas = await consultas.obtenerVentasPorDia();

    expect(ventasCobradas.isNotEmpty, true,
        reason: 'Debe haber al menos 1 venta cobrada en el dia actual');
  });

  test(
      'Si no existen ventas en un dia especificado, debe retornar un listado de ventas vacio',
      () async {
    var consultas = ModuloVentas.repositorioConsultaVentas();
    DateTime fecha = DateTime.now().subtract(const Duration(days: 30));
    var ventasCobradas = await consultas.obtenerVentasPorDia(fechaReporte: fecha);

    expect(ventasCobradas.isEmpty, true,
        reason: 'Debe de regresar una lista vacia si no hay ventas en el dia');
  });

  test('Debe obtener el listado de articulos de una venta cobrada', () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloVentas.repositorioConsultaVentas();

    var cantidad = 3.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;
    Venta ventaEnProgreso = Venta.crear();

    var producto = ProductosUtils.crearProducto(
      codigo: 'MountainDew600',
      nombre: 'MountainDew 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);

    producto = ProductosUtils.crearProducto(
      codigo: 'Pepsi600',
      nombre: 'Pepsi 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);

   
    var formasDisponibles = await consultas.obtenerFormasDePago();
    var pago = Pago.crear( 
      forma: formasDisponibles.first,
      monto: Moneda(146466.00),
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    //obtener las ventas del dia actual
    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    expect(ventaCobrada?.articulos.isNotEmpty, true,
        reason: 'Debe haber al menos 1 articulo en venta cobrada');
  });

  test(
      'Debe obtener los articulos cobrados en un solo renglon, de una venta en especifico',
      () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloVentas.repositorioConsultaVentas();

    var cantidad = 3.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;
    Venta ventaEnProgreso = Venta.crear();

    var producto = ProductosUtils.crearProducto(
      codigo: 'MountainDew600',
      nombre: 'MountainDew 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);

    producto = ProductosUtils.crearProducto(
      codigo: 'Pepsi600',
      nombre: 'Pepsi 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);

   
    var formasDisponibles = await consultas.obtenerFormasDePago();
    var pago = Pago.crear( 
      forma: formasDisponibles.first,
      monto: Moneda(146466.00),
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    //obtener las ventas del dia actual
    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    expect(ventaCobrada?.resumenArticulos?.isNull, false,
        reason: 'Debe regresar un resumen de articulos cobrados');
    expect(ventaCobrada?.resumenArticulos?.isNotEmpty, true,
        reason: 'Debe regresar un resumen de articulos cobrados no vacio');
  });

  test('Debe obtener el listado de pagos realizado a una venta cobrada',
      () async {
    var consultas = ModuloVentas.repositorioConsultaVentas();
    var ventasCobradas = await consultas.obtenerVentasPorDia();

    expect(ventasCobradas.isNotEmpty, true,
        reason: 'Debe de regresar una lista de ventas cobradas en el dia');
    expect(ventasCobradas.first.pagos.isNotEmpty, true,
        reason: 'Debe de regresar una lista de pagos realizados a una venta');
   
  });

  test('Debe obtener el listado de impuestos cobrados por venta', () async {
    var cobrarVenta = ModuloVentas.cobrarVenta();
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloVentas.repositorioConsultaVentas();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;
    Venta ventaEnProgreso = Venta.crear();

    List<Impuesto> impuestos = [];
    impuestos.add(Impuesto.crear(
        nombre: 'IVA 16%', porcentaje: PorcentajeDeImpuesto(16.00), ordenDeAplicacion: 1));
    impuestos.add(Impuesto.crear(
       nombre: 'IVA 8%', porcentaje: PorcentajeDeImpuesto(8.00), ordenDeAplicacion: 1));

    var producto = ProductosUtils.crearProducto(
      codigo: 'MountainDew600',
      nombre: 'MountainDew 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      impuestos: impuestos,
      
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);

    producto = ProductosUtils.crearProducto(
      codigo: 'Pepsi600',
      nombre: 'Pepsi 600 ml',
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      impuestos: impuestos,
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    ventaEnProgreso.agregarArticulo(articulo);

   
    var formasDisponibles = await consultas.obtenerFormasDePago();
    var pago = Pago.crear( 
      forma: formasDisponibles.first,
      monto: Moneda(146466.00),
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;
    await cobrarVenta.exec();

    //obtener las ventas del dia actual
    VentaDto? ventaCobrada = await consultas.obtenerVenta(ventaEnProgreso.uid);

    expect(ventaCobrada?.totalesDeImpuestos.isNotEmpty, true,
        reason: 'Debe de regresar una lista de impuestos aplicados a los articulos cobrados');
  });

  test('Debe obtener el listado de formas de pago disponibles', () async {
    var consultas = ModuloVentas.repositorioConsultaVentas();
    var formasDePagoDisponibles = await consultas.obtenerFormasDePago();

    expect(formasDePagoDisponibles.isNotEmpty, true,
        reason: 'Debe de regresar una lista de formas de pago disponibles para pago de ventas');
  });
}
