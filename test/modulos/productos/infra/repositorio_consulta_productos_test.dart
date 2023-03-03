import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/dto/busqueda_producto_dto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';
import '../../../utils/database.dart';
import '../../../utils/productos.dart';

void main() {
  TestDatabaseUtils? testDbUtils;

  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  tearDown(() async {
    testDbUtils ??= TestDatabaseUtils();

    await testDbUtils!.limpar(tabla: 'productos');
    await testDbUtils!.limpar(tabla: 'productos_busqueda');
  });

  test('debe de obtener un producto activo', () async {
    var crearProducto = ModuloProductos.crearProducto();
    var repo = ModuloProductos.repositorioConsultaProductos();

    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var unidadesMedida = await repo.obtenerUnidadesDeMedida();

    var productoCreado = Producto.crear(
        codigo: CodigoProducto('12343434343'),
        nombre: NombreProducto(nombre),
        precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
        precioDeVenta: PrecioDeVentaProducto(precioDeCompra),
        unidadDeMedida: unidadesMedida.first);

    crearProducto.req.producto = productoCreado;

    await crearProducto.exec();

    var productoEsperado = repo.obtenerProducto(productoCreado.uid);
    expect(productoEsperado, isNotNull,
        reason: 'El producto recien creado se debió haber obtenido');
  });

  test(
      'debe regresar los productos cuyo criterio de busqueda concuerde para el nombre de producto',
      () async {
    final repo = ModuloProductos.repositorioConsultaProductos();
    final crearProducto = ModuloProductos.crearProducto();

    final categorias = await repo.obtenerCategorias();

    final prod1 = ProductosUtils.crearProducto(
        codigo: '1', nombre: 'CocaCola 600ml', categoria: categorias.first);
    final prod2 = ProductosUtils.crearProducto(
        codigo: '2', nombre: 'Refresco de Cola 250ml');
    final prod3 =
        ProductosUtils.crearProducto(codigo: '3', nombre: 'Tomate por Kg');
    final prod4 = ProductosUtils.crearProducto(
        codigo: '4', nombre: 'Refresco de Coca de 2 litros');

    crearProducto.req.producto = prod1;
    await crearProducto.exec();

    crearProducto.req.producto = prod2;
    await crearProducto.exec();

    crearProducto.req.producto = prod3;
    await crearProducto.exec();

    crearProducto.req.producto = prod4;
    await crearProducto.exec();

    const criterio = 'coca';
    List<BusquedaProductoDto> resultados =
        await repo.buscarProductos(criterio: criterio, limite: 10);

    expect(resultados.length, 2);

    expect(
        resultados
            .where((producto) => producto.productoUid == prod1.uid.toString())
            .first,
        isNotNull,
        reason:
            'debe regresar el primer producto que contiene "coca" en su nombre');

    expect(
        resultados
            .where((producto) => producto.productoUid == prod4.uid.toString())
            .first,
        isNotNull,
        reason:
            'debe regresar el segundo producto que contiene "coca" en su nombre');

    var primerResultado = resultados
        .where((producto) => producto.productoUid == prod1.uid.toString())
        .first;

    expect(primerResultado.codigo, isNotEmpty,
        reason: 'codigo no debe de estar vacio');
    expect(primerResultado.nombre, isNotEmpty,
        reason: 'nombre no debe de estar vacio');
    expect(primerResultado.nombreCategoria, isNotEmpty,
        reason: 'nombre de categoria no debe de estar vacio');
    expect(primerResultado.precioDeVenta, isNot(Moneda(0)),
        reason: 'precio de venta no debe de ser 0');
    expect(primerResultado.productoUid, isNotEmpty,
        reason: 'uid de producto no debe de estar vacio');
  });

  test(
      'debe regresar los productos cuyo criterio de busqueda concuerde para el codigo de producto',
      () async {
    var crearProducto = ModuloProductos.crearProducto();

    final prod1 = ProductosUtils.crearProducto(codigo: '7622300117207');

    crearProducto.req.producto = prod1;
    await crearProducto.exec();

    final repo = ModuloProductos.repositorioConsultaProductos();

    const criterio = '7622';
    List<BusquedaProductoDto> resultados =
        await repo.buscarProductos(criterio: criterio);

    expect(resultados.length, 1);

    expect(
        resultados
            .where((producto) => producto.productoUid == prod1.uid.toString())
            .first,
        isNotNull,
        reason:
            'debe regresar un producto que contenga parcialmente el codigo "7622300117207"');
  });

  test(
      'debe regresar los productos cuando el criterio de busqueda es por categoria',
      () async {
    final repo = ModuloProductos.repositorioConsultaProductos();
    final crearProducto = ModuloProductos.crearProducto();

    final categorias = await repo.obtenerCategorias();
    final categoriaDeBusqueda = categorias.last;

    final producto = ProductosUtils.crearProducto(
      codigo: 'BUSCAT',
      nombre: 'Galletas Honey Bran',
      categoria: categoriaDeBusqueda,
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    List<BusquedaProductoDto> resultados =
        await repo.buscarProductos(criterio: categoriaDeBusqueda.nombre);

    expect(resultados.length, 1);

    expect(
        resultados
            .where((productoBuscado) =>
                productoBuscado.productoUid == producto.uid.toString())
            .first,
        isNotNull,
        reason:
            'debe regresar el producto donde su categoria es ${categoriaDeBusqueda.nombre}');
  });

  test(
      'debe regresar los productos cuando la categoría fue renombrada y se busca por el nuevo nombre',
      () async {
    final repo = ModuloProductos.repositorioConsultaProductos();
    final crearProducto = ModuloProductos.crearProducto();

    final categorias = await repo.obtenerCategorias();
    var categoriaDeBusqueda = categorias.first;

    final producto = ProductosUtils.crearProducto(
      categoria: categoriaDeBusqueda,
    );

    crearProducto.req.producto = producto;
    await crearProducto.exec();

    const nuevoNombreCategoria = 'Teléfonos Inteligentes';
    final modificarCategoria = ModuloProductos.modificarCategoria();
    var categoriaModificada = categoriaDeBusqueda.copyWith(
      nombre: NombreCategoria(nuevoNombreCategoria),
    );
    modificarCategoria.req.categoria = categoriaModificada;
    await modificarCategoria.exec();

    List<BusquedaProductoDto> resultados =
        await repo.buscarProductos(criterio: 'inteligent');

    expect(resultados.length, 1);

    var productoBuscado = resultados.first;
    expect(productoBuscado.nombreCategoria, nuevoNombreCategoria);
  });

  test(
      'debe obtener los productos correctamente despues de haber cambiado sus datos',
      () async {
    final crearProducto = ModuloProductos.crearProducto();
    final repo = ModuloProductos.repositorioConsultaProductos();
    final guardarProducto = ModuloProductos.modificarProducto();

    var unidadesMedida = await repo.obtenerUnidadesDeMedida();

    final prod1 = ProductosUtils.crearProducto(
      codigo: 'A23',
      nombre: 'gansito verde',
      unidadDeMedida: unidadesMedida.first,
    );

    crearProducto.req.producto = prod1;
    await crearProducto.exec();

    final productoGuardado = (await repo.obtenerProducto(prod1.uid))!
        .copyWith(nombre: NombreProducto('ganzito verdoso'));

    guardarProducto.req.producto = productoGuardado;
    await guardarProducto.exec();

    List<BusquedaProductoDto> resultados =
        await repo.buscarProductos(criterio: 'gansito', limite: 10);

    expect(resultados.length, 0);

    resultados = await repo.buscarProductos(criterio: 'ganzito', limite: 10);

    expect(resultados.length, 1);

    expect(
        resultados
            .where((producto) =>
                producto.productoUid == productoGuardado.uid.toString())
            .first,
        isNotNull,
        reason:
            'debe regresar el primer producto que contiene "ganzito" en su nombre');
  });

  test(
      'debe asignar categoria nula para aquellos productos con categoria borrada',
      () async {
    var repo = ModuloProductos.repositorioConsultaProductos();
    var unidadesMedida = await repo.obtenerUnidadesDeMedida();
    var categorias = await repo.obtenerCategorias();

    var crearProducto = ModuloProductos.crearProducto();

    var productoCreado = Producto.crear(
        codigo: CodigoProducto('123456AAAABB'),
        nombre: NombreProducto('Producto con categoria borrada'),
        precioDeCompra: PrecioDeCompraProducto(Moneda(11.42)),
        precioDeVenta: PrecioDeVentaProducto(Moneda(11.50)),
        unidadDeMedida: unidadesMedida.first,
        impuestos: [],
        categoria: categorias.first);

    crearProducto.req.producto = productoCreado;

    await crearProducto.exec();

    var eliminarCategoria = ModuloProductos.eliminarCategoria();
    eliminarCategoria.req.uidCategoria = categorias.first.uid;
    await eliminarCategoria.exec();

    var productoEsperado = await repo.obtenerProducto(productoCreado.uid);

    expect(productoEsperado!.categoria, isNull,
        reason: 'La categoria del producto que fue eliminada debe ser nula');
  });

  test('debe obtener las categorias activas', () async {
    final crearCategoria = ModuloProductos.crearCategoria();
    final eliminarCategoria = ModuloProductos.eliminarCategoria();
    final consultas = ModuloProductos.repositorioConsultaProductos();

    final categoria = Categoria.crear(nombre: NombreCategoria('Abarrotes'));

    crearCategoria.req.categoria = categoria;

    await crearCategoria.exec();

    eliminarCategoria.req.uidCategoria = categoria.uid;
    await eliminarCategoria.exec();

    final categorias = await consultas.obtenerCategorias();

    final countCategoriasEliminadas = categorias.where((cat) => cat.eliminado);

    expect(countCategoriasEliminadas.length, 0,
        reason: 'No se deben obtener las categorias eliminadas');
  });

  test('debe de obtener un producto solo con sus impuestos activos', () async {
    var repo = ModuloProductos.repositorioConsultaProductos();

    var crearProducto = ModuloProductos.crearProducto();
    const nombre = 'Atun tunny 200 grs.';
    final precioDeCompra = Moneda(10.40);

    var impuestosActivos = await repo.obtenerImpuestos();
    var unidadesMedida = await repo.obtenerUnidadesDeMedida();

    var productoCreado = Producto.crear(
      codigo: CodigoProducto('TOMATE'),
      nombre: NombreProducto(nombre),
      precioDeCompra: PrecioDeCompraProducto(precioDeCompra),
      precioDeVenta: PrecioDeVentaProducto(precioDeCompra),
      impuestos: [impuestosActivos.first],
      unidadDeMedida: unidadesMedida.first,
    );

    crearProducto.req.producto = productoCreado;

    var impuestosProductoModificado = [
      impuestosActivos[1],
      impuestosActivos[2]
    ];

    await crearProducto.exec();
    var productoModificado =
        productoCreado.copyWith(impuestos: impuestosProductoModificado);
    var modificarProducto = ModuloProductos.modificarProducto();
    modificarProducto.req.producto = productoModificado;
    await modificarProducto.exec();

    var productoEsperado = await repo.obtenerProducto(productoCreado.uid);
    expect(
      productoEsperado!.impuestos.length,
      impuestosProductoModificado.length,
      reason: 'El producto modificado solo debe contener un impuesto',
    );

    expect(
      setEquals(
        productoEsperado.impuestos.toSet(),
        impuestosProductoModificado.toSet(),
      ),
      true,
      reason: 'La lista de impuestos del producto no es la esperada',
    );
  });

  test('debe regresar solo los productos del parametro limite', () async {
    var crearProducto = ModuloProductos.crearProducto();

    for (var i = 1; i <= 10; i++) {
      var producto = ProductosUtils.crearProducto(
        codigo: 'A$i',
        nombre: 'Producto $i',
      );
      crearProducto.req.producto = producto;
      await crearProducto.exec();
    }

    final repo = ModuloProductos.repositorioConsultaProductos();

    List<BusquedaProductoDto> resultados =
        await repo.buscarProductos(criterio: 'Prod', limite: 10);

    expect(resultados.length, 10);
  });

  /// El indice de la búsqueda contempla el código, nombre de producto y categoría para que
  /// al buscar se contemplen todos estos campos.
  /// Se usan los siguientes valores como valores de peso (weight) por campo:
  /// nombre - 20.0, código - 10.0, categoría - 5.0.
  test('debe regresar los productos ordenados por peso (rank)', () async {
    var crearProducto = ModuloProductos.crearProducto();
    final consultas = ModuloProductos.repositorioConsultaProductos();

    final categorias = await consultas.obtenerCategorias();

    var productoCodigo = ProductosUtils.crearProducto(codigo: 'fruta');

    var productoNombre =
        ProductosUtils.crearProducto(nombre: 'fruta de la pasion');

    var categoriaEsperada = categorias.last;

    var productoCategoria =
        ProductosUtils.crearProducto(categoria: categoriaEsperada);

    crearProducto.req.producto = productoCodigo;
    await crearProducto.exec();

    crearProducto.req.producto = productoNombre;
    await crearProducto.exec();

    crearProducto.req.producto = productoCategoria;
    await crearProducto.exec();

    List<BusquedaProductoDto> resultados =
        await consultas.buscarProductos(criterio: 'fruta');

    expect(resultados.length, 3);

    expect(
        resultados
            .where((producto) =>
                producto.productoUid == productoNombre.uid.toString())
            .first,
        isNotNull,
        reason: 'debe regresar el producto que contiene fruta en su nombre');

    expect(resultados[0].nombre, productoNombre.nombre,
        reason:
            'debe regresar en primer lugar el producto que contiene fruta en su nombre');
    expect(resultados[1].codigo, productoCodigo.codigo,
        reason:
            'debe regresar en segundo lugar el producto que contiene fruta en su código');
    expect(resultados[2].nombreCategoria, categoriaEsperada.nombre,
        reason:
            'debe regresar en tercer lugar el producto que contiene fruta en su categoría');
  });

  test(
      'debe buscar correctamente cuando los productos tengan caracteres especiales',
      () async {
    var crearProducto = ModuloProductos.crearProducto();
    final consultas = ModuloProductos.repositorioConsultaProductos();

    final producto = ProductosUtils.crearProducto(nombre: r'Tuerca de 7"');
    crearProducto.req.producto = producto;
    await crearProducto.exec();

    List<BusquedaProductoDto> resultados =
        await consultas.buscarProductos(criterio: '7"');

    expect(resultados.length, 1);
  });

  test(
      'debe buscar correctamente cuando los productos tengan el caracter especial \\',
      () async {
    var crearProducto = ModuloProductos.crearProducto();
    final consultas = ModuloProductos.repositorioConsultaProductos();

    final producto =
        ProductosUtils.crearProducto(nombre: r'Tuerca de \diagnonal"');
    crearProducto.req.producto = producto;
    await crearProducto.exec();

    List<BusquedaProductoDto> resultados =
        await consultas.buscarProductos(criterio: r' tuerca \');

    expect(resultados.length, 1);
  });
}
