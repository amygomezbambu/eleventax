import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe actualizar los totales al agregar nuevos articulos', () {
    var cantidad = 2.00;
    var precioVenta = PrecioDeVentaProducto(Moneda(35.55444451111));
    var precioCompra = PrecioDeCompraProducto(Moneda(21.54444448));

    var producto = Producto.crear(
        codigo: CodigoProducto('123'),
        nombre: NombreProducto('Soda'),
        unidadDeMedida: UnidadDeMedida.crear(
          nombre: 'pieza',
          abreviacion: 'pz',
        ),
        precioDeCompra: precioCompra,
        precioDeVenta: precioVenta);
    var articulo = Articulo.crear(producto: producto, cantidad: cantidad);

    var venta = Venta.crear();
    venta.agregarArticulo(articulo);

    final subtotalEsperado =
        Moneda.deserialize(precioVenta.value.montoInterno * cantidad.toInt());

    final subtotalEsperadoEnMoneda =
        Moneda(subtotalEsperado.toString()).montoInterno;

    final totalImpuestosEsperados =
        Moneda.deserialize(precioVenta.value.montoInterno * 0);

    final totalImpuestosEsperadosEnMoneda =
        Moneda(totalImpuestosEsperados.toString()).montoInterno;

    final totalEsperado =
        subtotalEsperadoEnMoneda + totalImpuestosEsperadosEnMoneda;

    expect(venta.subtotal.montoInterno, subtotalEsperadoEnMoneda);

    expect(venta.totalImpuestos.montoInterno, totalImpuestosEsperadosEnMoneda);

    expect(venta.total.montoInterno,
        Moneda.deserialize(totalEsperado).montoInterno);
  });

  test('Debe actualizar los totales al eliminar algun articulo', () {});

  test('Debe actualizar los totales al modificar un articulo', () {});
}
