import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  // Venta crearVentaDePrueba(String cadenaArticulos, {required double tasaIVA}) {
  //   final impuestos = <Impuesto>[
  //     Impuesto.crear(nombre: 'IVA', porcentaje: tasaIVA, ordenDeAplicacion: 2),
  //   ];

  //   var venta = Venta.crear();

  //   // Separamos los articulos por el pipe
  //   var articulos = cadenaArticulos.split('|');
  //   for (var i = 0; i < articulos.length; i++) {
  //     var articulo = articulos[i];
  //     var datosArticulo = articulo.split('*');
  //     var cantidad = datosArticulo[0];
  //     var precio = datosArticulo[1];

  //     final precioConImpuestos = Moneda(precio);

  //     var producto = ProductosUtils.crearProducto(
  //       impuestos: impuestos,
  //       precioCompra: precioConImpuestos,
  //       precioVenta: precioConImpuestos,
  //     );

  //     var articuloDeVenta =
  //         Articulo.crear(producto: producto, cantidad: double.parse(cantidad));
  //     venta.agregarArticulo(articuloDeVenta);
  //   }

  //   return venta;
  // }

  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe actualizar los totales al agregar nuevos articulos', () {
    var cantidad = 2.00;
    var precioVenta = 24411.00;
    var precioSinImpuestos = precioVenta / 1.16;
    var precioCompra = 21.680000;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final subtotalEsperado =
        Moneda(precioSinImpuestos * cantidad).importeCobrable;

    // var totalDeImpuestos = Moneda(0);
    // for (var impuesto in producto.impuestos) {
    //   totalDeImpuestos +=
    // }

    //final totalImpuestosEsperados = Moneda(0).importeCobrable;

    //final totalEsperado = subtotalEsperado + totalImpuestosEsperados;

    expect(venta.subtotal, subtotalEsperado);
    // TODO: Probar lógica de total de impuestos y total a 2 decimales

    //   expect(venta.subtotal, subtotal_,
    //       reason:
    //           'el subtotal de la venta debe concordar con la suma de los precios de venta de los productos sin impuestos');

    //   expect(venta.totalImpuestos, totalImpuestos_,
    //       reason: 'el calculo de los impuestos es incorrecto');

    //   expect(venta.total, total_,
    //       reason:
    //           'el total de la venta debe concordar con la suma de los precios de venta de los productos más impuestos');
  });

  test('Debe actualizar los totales al agregar nuevos articulos', () {
    var cantidad = 2.00;
    var precioVenta = 41.2431556329;
    var precioSinImpuestos = precioVenta / 1.16;
    var precioCompra = 21.54444448;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final subtotalEsperado =
        Moneda(precioSinImpuestos * cantidad).importeCobrable;

    // var totalDeImpuestos = Moneda(0);
    // for (var impuesto in producto.impuestos) {
    //   totalDeImpuestos +=
    // }

    //final totalImpuestosEsperados = Moneda(0).importeCobrable;

    //final totalEsperado = subtotalEsperado + totalImpuestosEsperados;

    expect(venta.subtotal, subtotalEsperado);
    // TODO: Probar lógica de total de impuestos y total a 2 decimales
    //expect(venta.totalImpuestos, totalImpuestosEsperados);
    //expect(venta.total, totalEsperado);
    //expect(venta.creadoEn, fechaEsperada);
  });

  test(
      'debe sumar la cantidad y actualizar los totales cuando se agregue un producto ya existente a la venta',
      () {
    var cantidad = 2.00;
    var cantidad2 = 3.00;
    var precioVenta = 41.2431556329;
    var precioSinImpuestos = precioVenta / 1.16;
    var precioCompra = 21.54444448;
    var articulosEsperados = 1;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var articulo2 = Articulo.crear(producto: producto, cantidad: cantidad2);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);
    venta.agregarArticulo(articulo2);

    final cantidadEsperada = cantidad + cantidad2;
    final subtotalEsperado =
        Moneda((precioSinImpuestos * cantidadEsperada).toDouble())
            .importeCobrable;

    expect(
      venta.articulos.length,
      articulosEsperados,
      reason:
          'Debe de regresar unicamente 1 registro al agregar el mismo articulo',
    );
    expect(
      venta.articulos.first.subtotal.importeCobrable,
      subtotalEsperado,
      reason:
          'Debe actualizar el total de la venta cuando incrementa la cantidad de un artículo',
    );
    expect(venta.articulos.first.cantidad, cantidadEsperada,
        reason:
            'Debe sumar la cantidad cuando se agregue un producto ya existente a la venta');
  });

  test('debe cobrar una venta de IEPS e IVA', () {
    final precioConImpuestos = Moneda(24411.00);

    final impuestos = <Impuesto>[
      Impuesto.crear(nombre: 'IVA', porcentaje: 16.0, ordenDeAplicacion: 2),
    ];

    final impuestoMultiples = <Impuesto>[
      Impuesto.crear(nombre: 'IEPS', porcentaje: 8.0, ordenDeAplicacion: 1),
      ...impuestos,
    ];

    var producto = ProductosUtils.crearProducto(
      impuestos: impuestoMultiples,
      precioCompra: precioConImpuestos,
      precioVenta: precioConImpuestos,
    );

    var articulo = Articulo.crear(producto: producto, cantidad: 1);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final totalEsperado = Moneda(24411.00);
    final totalImpuestosEsperados = Moneda(4925.84);

    // expect(venta.totalDeImpuestos.length, impuestoMultiples.length,
    //     reason: 'Debe existir los totales de los impuestos cobrados');

    expect(venta.total, totalEsperado,
        reason:
            'el total de la venta debe concordar con la suma de los precios de venta de los productos más impuestos');

    expect(venta.totalImpuestos, totalImpuestosEsperados, skip: true);
  });

  // [TestCase('debe calcular totales correctos con IVA 8%, Escenario B','8,1*478.4141|3*258.9581|1*434.5229,')]
  // [TestCase('debe calcular totales correctos con IVA 16%, Escenario D','16,1*478.4141|3*258.9581|1*434.5229,')]
  // [TestCase('debe calcular totales correctos con IVA 16%, Escenario E','16,2*131.5425,')]
  // [TestCase('debe calcular totales correctos con IVA 16%, Escenario F','16,1*881.8966|1*991.38|1*1312.93|1*881.8966,4719.00')]
  // [TestCase('debe calcular totales correctos con IVA 16%, Escenario G','16,1*1325275.87,1537320.01')]
  // [TestCase('debe calcular totales correctos con IVA 16%, Escenario H','16,1*6.989960,')]
  // [TestCase('debe calcular totales correctos con IVA 16%, Escenario I','16,1*431.0345|1*108.4052|1*460.5604,1160.00')]
  test('Debe tener una fecha especificada al momento de crear la venta', () {
    //var fechaEsperada = DateTime.now();
  });

  //TODO: probar la comparacion de fechas entre la creacion del ticket y la establecida por la prueba
  // test(
  //     'Debe calcular correctamente los totales cuando se tenga IVA 8% - Escenario A',
  //     () {
  //   final venta = crearVentaDePrueba(
  //     '1*545.00|3*295.0000|1*495.00',
  //     tasaIVA: 8.0,
  //   );

  //   final subtotalEsperado = Moneda(1782.41);
  //   final totalImpuestosEsperado = Moneda(142.59);
  //   final totalEsperado = Moneda(1925);

  //   expect(venta.subtotal, subtotalEsperado,
  //       reason:
  //           'el subtotal de la venta debe concordar con la suma de los precios de venta de los productos sin impuestos');

  //   expect(venta.totalImpuestos, totalImpuestosEsperado,
  //       reason: 'el calculo de los impuestos es incorrecto');

  //   expect(venta.total, totalEsperado,
  //       reason:
  //           'el total de la venta debe concordar con la suma de los precios de venta de los productos más impuestos');
  // });

  // test(
  //     'Debe calcular correctamente los totales cuando se tenga IVA 16% - Escenario B',
  //     () {
  //   final venta = crearVentaDePrueba(
  //     '1*554.960356|3*300.391396|1*504.046564',
  //     tasaIVA: 16.0,
  //   );

  //   final subtotalEsperado = Moneda(1689.81);
  //   final totalImpuestosEsperado = Moneda(270.37);
  //   final totalEsperado = Moneda(1960.18);

  //   expect(venta.subtotal, subtotalEsperado,
  //       reason:
  //           'el subtotal de la venta debe concordar con la suma de los precios de venta de los productos sin impuestos');

  //   expect(venta.totalImpuestos, totalImpuestosEsperado,
  //       reason: 'el calculo de los impuestos es incorrecto');

  //   expect(venta.total, totalEsperado,
  //       reason:
  //           'el total de la venta debe concordar con la suma de los precios de venta de los productos más impuestos');
  // });
  test('Debe actualizar los totales al eliminar algun articulo', () {});

  test('Debe actualizar los totales al modificar un articulo', () {});
}
