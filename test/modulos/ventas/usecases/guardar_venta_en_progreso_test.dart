import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/producto_generico.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import '../../../loader_for_tests.dart';
import '../../../utils/productos.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('Debe persistir la venta en progreso si no esta vacia', () async {
    final guardar = ModuloVentas.guardarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final crearProducto = ModuloProductos.crearProducto();

    final consultasProductos = ModuloProductos.repositorioConsultaProductos();
    final unidadesMedida = await consultasProductos.obtenerUnidadesDeMedida();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var venta = Venta.crear();
    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      unidadDeMedida: unidadesMedida.first,
      impuestos: [],
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var articulo1 = Articulo.crear(producto: producto, cantidad: cantidad);
    venta.agregarArticulo(articulo1);

    guardar.req.venta = venta;
    await guardar.exec();

    final ventaDb = await consultas.obtenerVentaEnProgreso(venta.uid);

    expect(ventaDb, isNotNull, reason: 'la venta obtenida no debe ser nula');
    expect(
        ventaDb!.articulos
            .firstWhere((element) => element.uid == articulo1.uid),
        isNotNull,
        reason: 'la venta obtenida debe contener el artículo agregado');
    expect(ventaDb.total, isNot(Moneda(0)),
        reason: 'el total de la venta obtenida no debe ser cero');
    expect(ventaDb.subtotal != Moneda(0), true,
        reason: 'el subtotal de la venta obtenida no debe ser cero');
    //TODO: validar que tenga TODOS los datos que guardamos
  });

  test('Debe persistir la venta cuando un artículo es modificado', () async {
    final guardar = ModuloVentas.guardarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();
    final crearProducto = ModuloProductos.crearProducto();

    final consultasProductos = ModuloProductos.repositorioConsultaProductos();
    final unidadesMedida = await consultasProductos.obtenerUnidadesDeMedida();

    var cantidad = 1.00;
    var precioVenta = 24411.00;
    var precioCompra = 21.680000;

    var venta = Venta.crear();
    var producto = ProductosUtils.crearProducto(
      precioCompra: Moneda(precioCompra),
      precioVenta: Moneda(precioVenta),
      unidadDeMedida: unidadesMedida.first,
      impuestos: [],
    );

    final productoGenerico = ProductoGenerico.crear(
      nombre: NombreProducto('Chicles'),
      precioDeVenta: PrecioDeVentaProducto(Moneda(1000)),
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    var articulo1 = Articulo.crear(producto: producto, cantidad: cantidad);
    venta.agregarArticulo(articulo1);

    var articuloGenerico =
        Articulo.crear(producto: productoGenerico, cantidad: 1.0);
    venta.agregarArticulo(articuloGenerico);

    guardar.req.venta = venta;
    await guardar.exec();

    // Alteramos la cantidad del artículo
    final cantidadNuevaEsperada = cantidad + 10;
    articulo1 = articulo1.copyWith(cantidad: cantidadNuevaEsperada);

    venta.actualizarArticulo(articulo1);

    guardar.req.venta = venta;
    await guardar.exec();

    final ventaDb = await consultas.obtenerVentaEnProgreso(venta.uid);

    var articuloDb = ventaDb!.articulos.firstWhere(
        (element) => element.producto.uid == articulo1.producto.uid);

    expect(articuloDb.cantidad, cantidadNuevaEsperada, reason: 'Se debio de actualizar la cantidad del artículo aun guardada la venta');
  });

  test('Debe persistir la venta en progreso con productos genericos', () async {
    final guardar = ModuloVentas.guardarVenta();
    final consultas = ModuloVentas.repositorioConsultaVentas();

    final consultasProductos = ModuloProductos.repositorioConsultaProductos();

    var cantidad = 1.2345;
    var precioVenta = 24411.00;
    var nombreProducto = 'Chicles';

    final impuestos = await consultasProductos.obtenerImpuestos();

    var venta = Venta.crear();

    var productoGenerico = ProductoGenerico.crear(
      nombre: NombreProducto(nombreProducto),
      precioDeVenta: PrecioDeVentaProducto(Moneda(precioVenta)),
      impuestos: [impuestos.first],
    );

    var articulo =
        Articulo.crear(producto: productoGenerico, cantidad: cantidad);
    venta.agregarArticulo(articulo);

    guardar.req.venta = venta;
    await guardar.exec();

    final ventaDb = await consultas.obtenerVentaEnProgreso(venta.uid);

    expect(ventaDb, isNotNull, reason: 'la venta obtenida no debe ser nula');
    expect(
        ventaDb!.articulos.firstWhere((element) => element.uid == articulo.uid),
        isNotNull,
        reason: 'la venta obtenida debe contener el artículo agregado');
    expect(ventaDb.total, isNot(Moneda(0)),
        reason: 'el total de la venta obtenida no debe ser cero');
    expect(ventaDb.subtotal != Moneda(0), true,
        reason: 'el subtotal de la venta obtenida no debe ser cero');

    expect(ventaDb.articulos.first.producto, isA<ProductoGenerico>());
    expect(ventaDb.articulos.first.producto.nombre, nombreProducto);
    expect(ventaDb.articulos.first.producto.precioDeVenta.importeCobrable,
        Moneda(precioVenta));
    expect(ventaDb.articulos.first.producto.impuestos, isNotEmpty);
    expect(ventaDb.articulos.first.producto.impuestos.first, impuestos.first);
  });
}
