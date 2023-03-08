import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto_generico.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe usar datos del producto si se agrega un producto existente', () {
    //
    var cantidad = 2.0;
    var precioVentaConImpuestos = 35.55444451111;
    var precioCompra = 21.54444448;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVentaConImpuestos),
    );

    //TODO: probar optimistic locking cuando se actualice un producto

    final articulo = Articulo.crear(
      producto: producto,
      cantidad: cantidad,
    );

    expect(articulo.cantidad, cantidad);
    expect(articulo.producto, producto);
    expect(articulo.precioDeVenta, producto.precioDeVenta);
    expect(articulo.descripcion, producto.nombre);

    final subtotalEsperado =
        Moneda(producto.precioDeVentaSinImpuestos.toDouble() * cantidad);

    expect(articulo.subtotal, subtotalEsperado,
        reason: 'El subtotal no fue el correcto');

    final impuestoDeArticulo = Moneda(subtotalEsperado.toDouble() *
        (producto.impuestos.first.porcentaje.toPorcentajeDecimal()));
    expect(articulo.totalImpuestos.importeCobrable,
        impuestoDeArticulo.importeCobrable,
        reason:
            'El total de impuesto del articulo no se calculo correctamente');

    expect(articulo.total.importeCobrable,
        (subtotalEsperado + impuestoDeArticulo).importeCobrable,
        reason: 'El total del articulo no fue correcto');

    //TODO: corrobar fecha de agregado en
  });

  test(
      'debe usar los datos proporcionados al crear un artículo con producto genérico',
      () {
    var cantidad = 2.00;
    var precioVenta = PrecioDeVentaProducto(Moneda(35.55444451111));
    var descripcion = NombreProducto('Soda de lata');

    final productoGenerico = ProductoGenerico.crear(
      nombre: descripcion,
      precioDeVenta: precioVenta,
      impuestos: [],
    );

    final articulo = Articulo.crear(
      producto: productoGenerico,
      cantidad: cantidad,
    );

    expect(articulo.cantidad, cantidad);
    expect(articulo.producto, isA<ProductoGenerico>());
    expect(articulo.precioDeVenta, precioVenta.value);
    expect(articulo.descripcion, descripcion.value);
    expect(articulo.subtotal, Moneda(precioVenta.value.toDouble() * cantidad));
    expect(articulo.total, Moneda(precioVenta.value.toDouble() * cantidad));

    // TODO: Verificar totales calculados de un articulo generico
  });

  test('debe recalcular los totales al modificar la cantidad', () {
    var cantidad = 1.00;
    var cantidadAgregada = 3.00;
    var precioVentaConImpuestos = 35.55444451111;
    var precioCompra = 21.54444448;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVentaConImpuestos),
    );

    //TODO: probar optimistic locking cuando se actualice un producto

    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    articulo = articulo.copyWith(cantidad: cantidad + cantidadAgregada);

    var totalEsperado = (cantidad + cantidadAgregada) *
        Moneda(precioVentaConImpuestos).toDouble();

    expect(articulo.cantidad, cantidad + cantidadAgregada);
    expect(
        articulo.total.importeCobrable, Moneda(totalEsperado).importeCobrable,
        reason: 'El total del articulo no es el esperado');
  });

  test('debe lanzar un error si el precio de venta es nulo o cero', () {
    //
  });

  test(
      'debe calcular el precio sin impuestos de tal manera que al redondear los totales '
      'se obtenga el precio intriducido por el cliente', () {
    const cantidad = 1.0;
    const precioVenta = 24411.00;

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
      precioCompra: Moneda(precioVenta),
      precioVenta: Moneda(precioVenta),
      impuestos: impuestoMultiples,
    );

    final articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var totalImpuestos = 0.00;

    for (var totalDeImpuesto in articulo.totalesDeImpuestos) {
      totalImpuestos += totalDeImpuesto.monto.toDouble();
    }

    final totalEsperado =
        articulo.subtotal.importeCobrable + Moneda(totalImpuestos);

    expect(Moneda(precioVenta * cantidad).importeCobrable,
        totalEsperado.importeCobrable,
        reason: 'El total del articulo no fue correcto');
  }, skip: true);

  test(
      'debe calcular los totales correctamente a 2 decimales al agregar un producto con un solo impuesto',
      () {
    const cantidad = 1.0;
    const precioVenta = 11.55;

    final iva16 = Impuesto.crear(
        nombre: 'IVA',
        porcentaje: PorcentajeDeImpuesto(16.0),
        ordenDeAplicacion: 1);

    final impuestoMultiples = <Impuesto>[iva16];

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioVenta),
      precioVenta: Moneda(precioVenta),
      impuestos: impuestoMultiples,
    );

    final articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var totalImpuestos = 0.00;

    for (var totalDeImpuesto in articulo.totalesDeImpuestos) {
      totalImpuestos += totalDeImpuesto.monto.toDouble();
    }

    final totalEsperado =
        articulo.subtotal.importeCobrable + Moneda(totalImpuestos);

    expect(Moneda(precioVenta * cantidad), totalEsperado.importeCobrable,
        reason: 'El total del articulo no fue correcto');
  }, skip: true);

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
      precioCompra: Moneda(precioVentaConImpuestos),
      precioVenta: Moneda(precioVentaConImpuestos),
      impuestos: impuestoMultiples,
    );

    final articulo = Articulo.crear(
      producto: producto,
      cantidad: cantidad,
    );

    expect(articulo.total.importeCobrable.montoInterno,
        Moneda(precioVentaConImpuestos * cantidad).importeCobrable.montoInterno,
        reason: 'El total cobrable del articulo no fue correcto');
  }, skip: true);
}
