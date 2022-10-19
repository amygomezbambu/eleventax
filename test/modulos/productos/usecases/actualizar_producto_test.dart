import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe actualizar el item si los parametros son correctos', () async {
    var actualizarProducto = ModuloProductos.actualizarProducto();
    var crearProducto = ModuloProductos.crearProducto();
    var obtenerProducto = ModuloProductos.obtenerProducto();

    const codigo = '123456';
    const nombre = 'Atun tunny 200 grs.';
    const precioDeVenta = 13400000;
    const precioDeCompra = 10400000;

    var producto = Producto.crear(
      codigo: codigo,
      nombre: nombre,
      precioDeVenta: precioDeVenta,
      precioDeCompra: precioDeCompra,
      unidadDeMedida: UnidadDeMedida(
        uid: UID(),
        nombre: 'Pieza',
        abreviacion: 'pz',
      ),
    );

    crearProducto.req.producto = producto;

    await crearProducto.exec();

    var codigoActualizado = '1A2B3C';
    var precioDeVentaActualizado = 15500000;

    var producto2 = Producto.cargar(
      uid: producto.uid,
      codigo: codigoActualizado,
      nombre: nombre,
      precioDeVenta: precioDeVentaActualizado,
      precioDeCompra: precioDeCompra,
      unidadDeMedida: UnidadDeMedida(
        uid: UID(),
        nombre: 'Pieza',
        abreviacion: 'pz',
      ),
    );

    actualizarProducto.req.producto = producto2;

    await actualizarProducto.exec();

    obtenerProducto.req.uidProducto = producto.uid;

    final productoDeDB = await obtenerProducto.exec();

    expect(productoDeDB.codigo, codigoActualizado);
    expect(productoDeDB.precioDeVenta, precioDeVentaActualizado);
  });
}