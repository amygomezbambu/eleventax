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

  test('debe actualizar el producto si los parametros son correctos', () async {
    var actualizarProducto = ModuloProductos.modificarProducto();
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
    final versionOriginalDeProducto = producto.versionActual;

    const codigoActualizado = '1A2B3C';
    final precioDeVentaActualizado = Moneda(15.50);

    // Hacemos las modificaciones pertinentes
    producto = producto.copyWith(
      codigo: CodigoProducto(codigoActualizado),
      precioDeVenta: PrecioDeVentaProducto(precioDeVentaActualizado),
    );

    actualizarProducto.req.producto = producto;

    await actualizarProducto.exec();

    final productoDB = await consultas.obtenerProducto(producto.uid);

    expect(productoDB!.codigo, codigoActualizado);
    expect(productoDB.precioDeVenta, precioDeVentaActualizado);
    // TODO: Verificar el resto de las propiedades
    expect(productoDB.versionActual, isNot(versionOriginalDeProducto),
        reason:
            'La version actual del producto debió haber cambiado tras modificar');

    // Verificamos que se cree una nueva version del producto
    final productoVersion =
        await consultas.obtenerVersionDeProducto(productoDB.versionActual);

    // Verificamos que la version más reciente tenga los cambios
    expect(productoVersion!.codigo, codigoActualizado);
    expect(productoVersion.precioDeVenta, precioDeVentaActualizado);
    // TODO: Verificar el resto de las propiedades
  });
}
