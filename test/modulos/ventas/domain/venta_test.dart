import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_importe_con_impuestos.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_precio_sin_impuestos.dart';
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

  /// El total esperado es el precio que usuario introdujo por la cantidad
  /// sin tomar en cuenta impuestos
  test(
      'Debe actualizar los totales al agregar nuevos articulos considerando redondeos',
      () {
    for (var datosVenta in ventas) {
      var venta = Venta.crear();
      var totalEsperado = Moneda(0);

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
      }

      expect(venta.subtotal, isNot(Moneda(0)));
      expect(venta.total, isNot(Moneda(0)));

      var totalImpuestosEsperados = Moneda(0.00);
      for (var totalDeImpuesto in venta.totalDeImpuestos) {
        totalImpuestosEsperados += totalDeImpuesto.monto.importeCobrable;
      }

      expect(venta.totalImpuestos, totalImpuestosEsperados,
          reason: 'El totalImpuestos de la venta no fue el esperado');

      expect(
          venta.subtotal.importeCobrable + venta.totalImpuestos.importeCobrable,
          totalEsperado,
          reason: 'El subtotal + impuestos no fue igual al total esperado');

      expect(venta.total.importeCobrable, totalEsperado,
          reason: 'El total de la venta no fue el esperado');
    }
  });

  test(
      'debe sumar la cantidad y actualizar los totales cuando se agregue un producto ya existente a la venta',
      () {
    var cantidad = 2.00;
    var cantidad2 = 3.00;

    var precioVenta = 41.2431556329;

    var articulosEsperados = 1;

    var producto = ProductosUtils.crearProducto(
      precioVenta: Moneda(precioVenta),
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var articulo2 = Articulo.crear(producto: producto, cantidad: cantidad2);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);
    venta.agregarArticulo(articulo2);

    final cantidadEsperada = cantidad + cantidad2;

    expect(
      venta.articulos.length,
      articulosEsperados,
      reason:
          'Debe de regresar unicamente 1 registro al agregar el mismo articulo',
    );
    expect(
      venta.articulos.first.subtotal.importeCobrable.montoInterno,
      Moneda(177.78).montoInterno,
      reason: 'El subtotal de la venta debe ser el correcto',
    );
    expect(venta.articulos.first.cantidad, cantidadEsperada,
        reason:
            'Debe sumar la cantidad cuando se agregue un producto ya existente a la venta');
  });

  test(
      'debe sumar la cantidad a granel y actualizar los totales cuando se agregue un producto',
      () {
    var cantidad = 2.125;
    var cantidad2 = 3.879;
    var cantidad3 = 0.001;

    final precioVenta = PrecioDeVentaProducto(Moneda(41.2431556329));
    var articulosEsperados = 1;

    var producto = ProductosUtils.crearProducto(
      precioVenta: precioVenta.value,
      productoSeVendePor: ProductoSeVendePor.peso,
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var articulo2 = Articulo.crear(producto: producto, cantidad: cantidad2);
    var articulo3 = Articulo.crear(producto: producto, cantidad: cantidad3);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);
    venta.agregarArticulo(articulo2);
    venta.agregarArticulo(articulo3);

    final cantidadEsperada = cantidad + cantidad2 + cantidad3;

    final precioSinImpuestos = calcularPrecioSinImpuestos(
        precioVenta, producto.impuestos,
        paraCantidad: cantidadEsperada);

    // Como es el mismo producto y la cantidad se fue sumando debemos
    // considerar el precio sin impuestos usando el siguiente método
    final importesEsperados = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      producto.impuestos,
      paraCantidad: cantidadEsperada,
      comoImportesCobrables: true,
    );

    expect(
      venta.articulos.length,
      articulosEsperados,
      reason:
          'Debe de regresar unicamente 1 registro al agregar el mismo articulo',
    );
    expect(
      venta.articulos.first.subtotal.importeCobrable,
      importesEsperados.subtotal.importeCobrable,
      reason:
          'El subtotal del articulo debe ser el corracto para la cantidad sumada: ${importesEsperados.subtotal.importeCobrable}',
    );
    expect(venta.articulos.first.cantidad, cantidadEsperada,
        reason:
            'Debe sumar la cantidad cuando se agregue un producto ya existente a la venta');
  });

  test(
      'debe lanzar error cuando se agregue un producto que se vende a granel con cantidad menor a  0.001',
      () {
    var cantidad = 0.0001;

    var producto = ProductosUtils.crearProducto(
        productoSeVendePor: ProductoSeVendePor.peso);

    Object? error;
    try {
      Articulo.crear(producto: producto, cantidad: cantidad);
    } catch (e) {
      error = e;
    }

    expect(error, isA<ValidationEx>());
    expect((error as ValidationEx).tipo, TipoValidationEx.valorFueraDeRango,
        reason: 'Debe lanzar un error tipo valorFueraDeRango');
  });

  test(
      'debe lanzar error cuando se agregue un producto que se vende por unidad con cantidad decimal',
      () {
    var cantidad = 2.123;

    var producto = ProductosUtils.crearProducto(
        productoSeVendePor: ProductoSeVendePor.unidad);

    Object? error;
    try {
      Articulo.crear(producto: producto, cantidad: cantidad);
    } catch (e) {
      error = e;
    }

    expect(error, isA<ValidationEx>());
    expect(
      (error as ValidationEx).tipo,
      TipoValidationEx.valorFueraDeRango,
      reason: 'Debe lanzar un error tipo valorFueraDeRango',
    );
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

    expect(venta.totalDeImpuestos.length, impuestoMultiples.length,
        reason: 'Debe existir los totales de los impuestos cobrados');

    expect(venta.total, totalEsperado,
        reason: 'el total de la venta debe concordar con la suma de los '
            'precios de venta de los productos más impuestos');
  });

  test(
      'debe calcular el precio sin impuestos de tal manera que al redondear los totales '
      'se obtenga el precio intriducido por el cliente', () {
    const cantidad = 1.0;
    const precioConImpuestos = 24411.00;

    final ieps = Impuesto.crear(
        nombre: 'IEPS',
        porcentaje: PorcentajeDeImpuesto(8.0),
        ordenDeAplicacion: 1);
    final iva16 = Impuesto.crear(
        nombre: 'IVA',
        porcentaje: PorcentajeDeImpuesto(16.0),
        ordenDeAplicacion: 2);

    final impuestoMultiples = <Impuesto>[ieps, iva16];

    var producto = ProductosUtils.crearProducto(
      precioVenta: Moneda(precioConImpuestos),
      impuestos: impuestoMultiples,
    );

    final articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    // Cada impuesto debe sumarse por separado y redondearse a 2 decimales
    var totalImpuestosEsperados = Moneda(0.00);
    for (var totalDeImpuesto in venta.totalDeImpuestos) {
      totalImpuestosEsperados += totalDeImpuesto.monto;
    }

    final subtotalEsperado = articulo.subtotal.importeCobrable;
    final totalEsperado = Moneda(precioConImpuestos * cantidad).importeCobrable;

    expect(venta.subtotal, subtotalEsperado.importeCobrable,
        reason:
            'El subtotal de la venta no fue el resultado de redondear el subtotal a 2 decimales');

    expect(venta.totalImpuestos, totalImpuestosEsperados.importeCobrable,
        reason:
            'El totalDeImpuestos de la venta no fue el resultado de redondear el la suma de cada impuesto a 2 decimales');

    expect(venta.total, totalEsperado.importeCobrable,
        reason:
            'El total de la venta no fue el resultado de precioConImpuestos x Cantidad');
  });

  test(
      'debe calcular los totales correctamente a 2 decimales al agregar un producto con un solo impuesto',
      () {
    const cantidad = 1.0;
    const precioVentaConImpuestos = 11.55;

    final iva16 = Impuesto.crear(
        nombre: 'IVA',
        porcentaje: PorcentajeDeImpuesto(16.0),
        ordenDeAplicacion: 1);

    var producto = ProductosUtils.crearProducto(
      precioVenta: Moneda(precioVentaConImpuestos),
      impuestos: [iva16],
    );

    final articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    final venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final totalEsperado =
        Moneda(precioVentaConImpuestos * cantidad).importeCobrable;

    // Al ser un precio con solo 2 decimales y un impuesto
    // podemos sacar el subtotal con la siguiente operacion, en otros casos
    // mas complejos se debe usar la función calcularPrecioSinImpuestos
    final subtotalEsperado = Moneda(precioVentaConImpuestos / 1.16);

    final impuestosEsperados = totalEsperado - subtotalEsperado;

    expect(venta.total, totalEsperado,
        reason: 'El total de la venta no fue el esperado');

    expect(venta.subtotal, subtotalEsperado.importeCobrable,
        reason: 'El subtotal de la venta no fue el esperado');

    expect(venta.totalImpuestos, impuestosEsperados.importeCobrable,
        reason: 'El total del articulo no fue correcto');
  });

  test(
      'debe calcular los totales correctamente a 2 decimales al agregar un producto con precio pequeño',
      () {
    const cantidad = 5000.0;
    const precioVentaConImpuestos = 0.20;

    final ieps = Impuesto.crear(
        nombre: 'IEPS',
        porcentaje: PorcentajeDeImpuesto(8.0),
        ordenDeAplicacion: 1);
    final iva16 = Impuesto.crear(
        nombre: 'IVA',
        porcentaje: PorcentajeDeImpuesto(16.0),
        ordenDeAplicacion: 2);

    final impuestoMultiples = <Impuesto>[ieps, iva16];

    var producto = ProductosUtils.crearProducto(
      precioVenta: Moneda(precioVentaConImpuestos),
      impuestos: impuestoMultiples,
    );

    final articulo = Articulo.crear(
      producto: producto,
      cantidad: cantidad,
    );

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final precioSinImpuestos = calcularPrecioSinImpuestos(
      PrecioDeVentaProducto(Moneda(precioVentaConImpuestos)),
      impuestoMultiples,
      paraCantidad: cantidad,
    );

    expect(
        venta.total, Moneda(precioVentaConImpuestos * cantidad).importeCobrable,
        reason: 'El total de la venta no fue el esperado');

    expect(venta.subtotal, Moneda(precioSinImpuestos.toDouble() * cantidad),
        reason: 'El subtotal de la venta no fue el esperado');
  });

  test('Debe tener una fecha especificada al momento de crear la venta', () {
    //var fechaEsperada = DateTime.now();
  });

  test('Debe actualizar los totales al eliminar algun articulo', () {
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

    venta.eliminarArticulo(articulo2);

    final subtotalEsperado =
        Moneda((precioSinImpuestos * cantidad).toDouble()).importeCobrable;

    expect(
      venta.articulos.length,
      articulosEsperados,
      reason: 'Debe de regresar unicamente 1 registro al eliminar el articulo',
    );

    expect(
      venta.subtotal.importeCobrable,
      subtotalEsperado,
      reason: 'Debe actualizar el total de la venta cuando elimina un articulo',
    );
    expect(venta.articulos.first.cantidad, cantidad,
        reason:
            'Debe sumar la cantidad cuando se elimine un articulo ya existente a la venta');
  });

  test('Debe actualizar los totales al modificar un articulo', () {
    var cantidad = 2.00;
    var cantidad2 = 3.00;
    var cantidadNueva = 10.0;

    var precioVenta = 41.2431556329;
    var precioCompra = 21.54444448;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      nombre: 'Coca Cola 600ml',
    );

    var producto2 = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      nombre: 'Sandia Verde con Rojo',
    );

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);
    var articulo2 = Articulo.crear(producto: producto2, cantidad: cantidad2);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);
    venta.agregarArticulo(articulo2);

    articulo2 = articulo2.copyWith(cantidad: cantidadNueva);
    venta.actualizarArticulo(articulo2);

    final subtotalEsperado =
        articulo.subtotal.importeCobrable + articulo2.subtotal.importeCobrable;

    expect(
      articulo2.cantidad,
      cantidadNueva,
      reason: 'Debe de regresar el valor de la cantidad actualizada',
    );

    expect(
      venta.subtotal.importeCobrable,
      subtotalEsperado,
      reason:
          'Debe actualizar el total de la venta cuando actualiza la cantidad de un articulo',
    );
  });
}


//TODO: limpiar y completar pruebas
