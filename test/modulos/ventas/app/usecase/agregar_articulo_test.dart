import 'dart:ui';

import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/app/dto/articulo_de_venta.dart';
import 'package:eleventa/modulos/ventas/app/dto/venta_dto.dart';
import 'package:eleventa/modulos/ventas/domain/service/ventas_abiertas.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  // group('Agregar articulo a venta', () {
  //   test('debe agregar el articulo a la lista de articulos de la venta',
  //       () async {
  //     //having
  //     var crearVenta = ModuloVentas.crearVenta();
  //     var agregarArticulo = ModuloVentas.agregarArticulo();
  //     var productoComun = ArticuloDTO();

  //     //when
  //     var uid = crearVenta.exec();

  //     productoComun.descripcion = 'coca cola';
  //     productoComun.precio = 10.00;
  //     productoComun.cantidad = 2;

  //     agregarArticulo.req.ventaUID = uid;
  //     agregarArticulo.req.articulo = productoComun;

  //     var ventaDTO = await agregarArticulo.exec();

  //     //then
  //     expect(ventaDTO.articulos.length, 1);
  //   });

  //   test('debe calcular el total correctamente', () async {
  //     var crearVenta = ModuloVentas.crearVenta();
  //     var agregarArticulo = ModuloVentas.agregarArticulo();
  //     var productoComun = ArticuloDTO();

  //     var uid = crearVenta.exec();

  //     productoComun.descripcion = 'coca cola';
  //     productoComun.precio = 10.49;
  //     productoComun.cantidad = 2;

  //     agregarArticulo.req.ventaUID = uid;
  //     agregarArticulo.req.articulo = productoComun;

  //     await agregarArticulo.exec();

  //     var venta = VentasAbiertas.obtener(uid);

  //     var totalEsperado = 20.98;

  //     expect(venta.total, totalEsperado);
  //   });

  test('debe persistir la venta', () async {
    // var crearVenta = ModuloVentas.crearVenta();
    // var agregarArticulo = ModuloVentas.agregarArticulo();
    // var obtenerProductos = ModuloProductos.obtenerProductos();

    // var uid = crearVenta.exec();

    // var productos = await obtenerProductos.exec();

    // var dto = ArticuloDTO();
    // dto.descripcion = productos[0].descripcion;
    // dto.productoUID = productos[0].uid;
    // dto.precio = productos[0].precio;
    // dto.cantidad = 5;
    // dto.ventaUID = uid;

    // agregarArticulo.req.ventaUID = uid;
    // agregarArticulo.req.articulo = dto;

    // await agregarArticulo.exec();

    // var obtenerVenta = ModuloVentas.obtenerVenta();
    // obtenerVenta.req.ventaUID = uid;

    // VentaDTO venta = await obtenerVenta.exec();

    // expect(venta.uid, uid);
    // expect(venta.total, productos[0].precio * 5);
  });

  test('debe revertir la transacción en caso de falla', () async {
    // DartPluginRegistrant.ensureInitialized();

    // var crearVenta = ModuloVentas.crearVenta();
    // var agregarArticulo = ModuloVentas.agregarArticulo();
    // var obtenerProductos = ModuloProductos.obtenerProductos();
    // var obtenerVenta = ModuloVentas.obtenerVenta();

    // var uid = crearVenta.exec();

    // var items = await obtenerProductos.exec();

    // var dto = ArticuloDTO();
    // dto.descripcion = items[0].descripcion;
    // dto.productoUID = items[0].uid;
    // dto.precio = items[0].precio;
    // dto.cantidad = 5;
    // dto.ventaUID = uid;

    // agregarArticulo.req.ventaUID = uid;
    // agregarArticulo.req.articulo = dto;

    // await agregarArticulo.exec();

    // agregarArticulo = ModuloVentas.agregarArticulo();

    // agregarArticulo.req.ventaUID = uid;
    // agregarArticulo.req.articulo = dto;

    // await expectLater(agregarArticulo.exec(), throwsA(isA<InfraEx>()));

    // obtenerVenta.req.ventaUID = uid;
    // var venta = await obtenerVenta.exec();

    // //los totales de la venta aunque se persistieron deben de revertirse ya que
    // //trono la transaccion
    // expect(venta.total, dto.precio * dto.cantidad);
  });
  // });
}
