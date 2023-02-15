import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';
import '../../../utils/venta_helper.dart';

class DatosProducto {
  double cantidad;
  double precioDeVenta;
  List<Impuesto> impuestos;

  DatosProducto({
    required this.cantidad,
    required this.precioDeVenta,
    required this.impuestos,
  });
}

class DatosVenta {
  List<DatosProducto> productos;

  DatosVenta({required this.productos});
}

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe actualizar los totales al agregar nuevos articulos', () {
    for (var datosVenta in ventas) {
      var venta = Venta.crear();
      // ignore: unused_local_variable
      var totalEsperado = Moneda(0);
      var totalDeImpuestos = Moneda(0);

      for (var datosProducto in datosVenta.productos) {
        totalEsperado +=
            Moneda(datosProducto.precioDeVenta * datosProducto.cantidad)
                .importeCobrable;

        var producto = ProductosUtils.crearProducto(
          precioCompra: Moneda(10),
          precioVenta: Moneda(datosProducto.precioDeVenta),
          impuestos: datosProducto.impuestos,
        );

        var articulo = Articulo.crear(
            producto: producto, cantidad: datosProducto.cantidad);

        venta.agregarArticulo(articulo);

        for (var totalImpuesto in articulo.totalesDeImpuestos) {
          totalDeImpuestos += totalImpuesto.monto.importeCobrable;
        }
      }

      debugPrint('Subtotal: ${venta.subtotal.importeCobrable}');
      debugPrint('Impuestos: ${totalDeImpuestos.importeCobrable}');
      debugPrint('Total: ${venta.total.importeCobrable}');
      debugPrint('----------------------------');

      // expect(venta.total.importeCobrable, totalEsperado);
      // expect(venta.subtotal.importeCobrable + totalDeImpuestos.importeCobrable,
      //     venta.total.importeCobrable);

      expect(venta.subtotal, isNot(Moneda(0)));
      expect(venta.total, isNot(Moneda(0)));
    }
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
      Impuesto.crear(
          nombre: 'IVA',
          porcentaje: PorcentajeDeImpuesto(16.0),
          ordenDeAplicacion: 2),
    ];

    final impuestoMultiples = <Impuesto>[
      Impuesto.crear(
          nombre: 'IEPS',
          porcentaje: PorcentajeDeImpuesto(8.0),
          ordenDeAplicacion: 1),
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

    // expect(venta.totalDeImpuestos.length, impuestoMultiples.length,
    //     reason: 'Debe existir los totales de los impuestos cobrados');

    expect(venta.total, totalEsperado,
        reason: 'el total de la venta debe concordar con la suma de los '
            'precios de venta de los productos más impuestos');
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

  test('Debe actualizar los totales al eliminar algun articulo', () {});

  test('Debe actualizar los totales al modificar un articulo', () {});
}
