import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
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
    var cantidad = 2.45677;
    var precioVenta = 35.55444451111;
    var precioCompra = 21.54444448;

    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
    );

    final articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    expect(articulo.cantidad, cantidad);
    expect(articulo.producto, producto);
    expect(articulo.precioDeVenta, producto.precioDeVenta);
    expect(articulo.descripcion, producto.nombre);

    final subtotalEsperado =
        Moneda(producto.precioDeVenta!.toDouble() * cantidad);
    expect(articulo.subtotal, subtotalEsperado,
        reason: 'El subtotal no fue el correcto');

    final impuestoDeArticulo = Moneda(subtotalEsperado.toDouble() *
        (producto.impuestos.first.porcentaje / 100));
    expect(articulo.totalImpuestos, impuestoDeArticulo,
        reason:
            'El total de impuesto del articulo no se calculo correctamente');

    expect(articulo.total, subtotalEsperado + impuestoDeArticulo,
        reason: 'El total del articulo no fue correcto');

    //TODO: corrobar fecha de agregado en
  });

  test(
      'debe usar los datos proporcionados al crear un artículo con producto genérico',
      () {
    var cantidad = 2.00;
    var precioVenta = PrecioDeVentaProducto(Moneda(35.55444451111));
    var descripcion = NombreProducto('Soda de lata');

    final articulo = Articulo.crearDesdeProductoGenerico(
        descripcion: descripcion,
        cantidad: cantidad,
        precioDeVenta: precioVenta.value);

    expect(articulo.cantidad, cantidad);
    expect(articulo.producto, null);
    expect(articulo.precioDeVenta, precioVenta.value);
    expect(articulo.descripcion, descripcion.value);
    expect(articulo.subtotal, Moneda(precioVenta.value.toDouble() * cantidad));
    expect(articulo.total, Moneda(precioVenta.value.toDouble() * cantidad));

    // TODO: Verificar totales calculados de un articulo generico
  });

  test('debe recalcular los totales al modificar la cantidad', () {
    //
  });

  test('debe lanzar un error si el precio de venta es nulo o cero', () {
    //
  });
}
