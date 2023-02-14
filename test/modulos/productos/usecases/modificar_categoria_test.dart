import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('debe modificar categoria si los datos son correctos', () async {
    final consultas = ModuloProductos.repositorioConsultaProductos();
    final crearCategoria = ModuloProductos.crearCategoria();
    final modificarCategoria = ModuloProductos.modificarCategoria();

    final nombreCategoria = NombreCategoria('lacteos');
    final nuevoNombreCategoria = NombreCategoria('Bebidas Alcoholicas');
    var categoria = Categoria.crear(nombre: nombreCategoria);
    crearCategoria.req.categoria = categoria;
    await crearCategoria.exec();

    var categoriaDB = await consultas.obtenerCategoria(categoria.uid);
    var categoriaModificada =
        categoriaDB!.copyWith(nombre: nuevoNombreCategoria);

    modificarCategoria.req.categoria = categoriaModificada;
    await modificarCategoria.exec();

    final categoriaEsperada = await consultas.obtenerCategoria(categoria.uid);

    expect(categoriaEsperada!.nombre, nuevoNombreCategoria.value,
        reason: 'No se modificó el nombre de la categoria');
  });

  test('debe de lanzar error si modifico el nombre por uno ya existente',
      () async {
    final consultas = ModuloProductos.repositorioConsultaProductos();
    final crearCategoria = ModuloProductos.crearCategoria();
    final modificarCategoria = ModuloProductos.modificarCategoria();

    final nombreCategoriaExistente = NombreCategoria('Categoria Uno');

    final categoriaUno = Categoria.crear(nombre: nombreCategoriaExistente);
    crearCategoria.req.categoria = categoriaUno;
    await crearCategoria.exec();

    final categoriaDos =
        Categoria.crear(nombre: NombreCategoria('Categoria Dos'));
    crearCategoria.req.categoria = categoriaDos;
    await crearCategoria.exec();

    var categoriaDB = await consultas.obtenerCategoria(categoriaDos.uid);
    var categoriaModificada =
        categoriaDB!.copyWith(nombre: nombreCategoriaExistente);

    modificarCategoria.req.categoria = categoriaModificada;

    await expectLater(
      () => modificarCategoria.exec(),
      throwsA(isA<ValidationEx>()),
      reason:
          'Se debio lanzar error al modificar nombre de una categoria que ya existe',
    );
  });
}
