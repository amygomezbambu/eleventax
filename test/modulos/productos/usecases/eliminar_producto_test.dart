import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe eliminar el producto', () async {
    var eliminarProducto = ModuloProductos.eliminarProducto();
    var crearProducto = ModuloProductos.crearProducto();
    var consultas = ModuloProductos.repositorioConsultaProductos();

    const codigo = '123456';
    const nombre = 'Atun tunny 200 grs.';
    final precioDeVenta = Moneda(13.40);
    final precioDeCompra = Moneda(10.40);

    var unidadesMedida = await consultas.obtenerUnidadesDeMedida();

    var producto = Producto.crear(
      codigo: CodigoProducto(codigo),
      nombre: NombreProducto(nombre),
      precioDeVenta: PrecioDeVentaProducto(precioDeVenta),
      precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
      unidadDeMedida: unidadesMedida.first,
    );

    crearProducto.req.producto = producto;

    await crearProducto.exec();

    eliminarProducto.req.uidProducto = producto.uid;

    await eliminarProducto.exec();

    final productoDB = await consultas.obtenerProducto(producto.uid);

    expect(productoDB!.eliminado, true,
        reason: 'El producto consultado NO esta eliminado');
  });
}
