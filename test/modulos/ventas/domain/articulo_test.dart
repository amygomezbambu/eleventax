import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe usar datos del producto si se agrega un producto existente', () {
    //
    var cantidad = 2.00;
    var precioVenta = PrecioDeVentaProducto(Moneda(35.55444451111));
    var precioCompra = PrecioDeCompraProducto(Moneda(21.54444448));
    final producto = Producto.crear(
        codigo: CodigoProducto('123'),
        nombre: NombreProducto('Soda'),
        unidadDeMedida: UnidadDeMedida.crear(
          nombre: 'pieza',
          abreviacion: 'pz',
        ),
        precioDeCompra: precioCompra,
        precioDeVenta: precioVenta);
    final articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    expect(articulo.cantidad, cantidad);
    expect(articulo.producto, producto);
    expect(articulo.precioDeVenta, producto.precioDeVenta);
    expect(articulo.descripcion, producto.nombre);
    expect(articulo.subtotal,
        Moneda(producto.precioDeVenta!.toDouble() * cantidad));
    expect(
        articulo.total, Moneda(producto.precioDeVenta!.toDouble() * cantidad));

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
  });

  test('debe recalcular los totales al modificar la cantidad', () {
    //
  });

  test('debe lanzar un error si el precio de venta es nulo o cero', () {
    //
  });
}
